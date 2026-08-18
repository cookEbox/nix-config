#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  concat [OPTIONS]
  concat [OUTPUT_DIR] [SCAN_ROOT]

Safely concatenate source/text files under SCAN_ROOT into one output file.

Default behaviour:
  * Uses `git ls-files -co --exclude-standard` inside Git repositories.
  * Respects .gitignore for untracked files.
  * Includes only an explicit allowlist of source/text file types.
  * Excludes build/cache/database/media/generated-output trees.
  * Excludes filenames that look like credentials or private keys.
  * Skips files larger than 1 MiB by default.
  * Refuses binary files even when their extension is allowlisted.

Options:
  -s, --source DIR          Root directory to scan (default: .)
  -t, --target DIR          Output directory (default: .)
      --output-dir DIR      Alias for --target
  -o, --output NAME         Output filename (default: all_files_output.txt)
      --output-file NAME    Alias for --output
      --max-bytes N         Maximum input file size in bytes (default: 1048576)
      --include-sensitive   Disable filename-based secret filtering
      --no-git              Do not use Git enumeration; fall back to find
  -h, --help                Show this help and exit

Outputs:
  TARGET_DIR/OUTPUT

Examples:
  concat --source /path/to/project --target /tmp --output project.txt
  concat -s . -t /tmp -o all_files_output.txt
  concat -s . -t /tmp --max-bytes 2097152

Backwards-compatible positional usage:
  concat . /path/to/project
  concat /tmp .
EOF
}

if [ "$#" -eq 0 ]; then
  usage
  exit 0
fi

output_dir="."
base_dir="."
output_name="all_files_output.txt"
max_bytes=1048576
include_sensitive=0
use_git=1

while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;

    -s|--source)
      if [ -z "${2:-}" ]; then
        echo "Error: --source requires a directory argument." >&2
        usage >&2
        exit 2
      fi
      base_dir="$2"
      shift 2
      ;;

    -t|--target|--output-dir)
      if [ -z "${2:-}" ]; then
        echo "Error: --target requires a directory argument." >&2
        usage >&2
        exit 2
      fi
      output_dir="$2"
      shift 2
      ;;

    -o|--output|--output-file)
      if [ -z "${2:-}" ]; then
        echo "Error: --output requires a filename argument." >&2
        usage >&2
        exit 2
      fi
      output_name="$2"
      shift 2
      ;;

    --max-bytes)
      if [ -z "${2:-}" ] || ! [[ "$2" =~ ^[0-9]+$ ]]; then
        echo "Error: --max-bytes requires a non-negative integer." >&2
        exit 2
      fi
      max_bytes="$2"
      shift 2
      ;;

    --include-sensitive)
      include_sensitive=1
      shift
      ;;

    --no-git)
      use_git=0
      shift
      ;;

    --)
      shift
      break
      ;;

    -*)
      echo "Error: unknown option: $1" >&2
      usage >&2
      exit 2
      ;;

    *)
      break
      ;;
  esac
done

# Backwards-compatible positional parsing:
#   concat [OUTPUT_DIR] [SCAN_ROOT]
if [ "$#" -gt 2 ]; then
  echo "Error: too many positional arguments." >&2
  usage >&2
  exit 2
fi

if [ "$#" -ge 1 ]; then
  output_dir="$1"
  shift
fi

if [ "$#" -ge 1 ]; then
  base_dir="$1"
  shift
fi

if [ ! -d "$base_dir" ]; then
  echo "Error: source directory does not exist or is not a directory: $base_dir" >&2
  exit 2
fi

mkdir -p "$output_dir"
output_file="${output_dir%/}/${output_name}"
mkdir -p "$(dirname -- "$output_file")"

# Canonical paths make self-exclusion reliable even when relative paths differ.
base_dir_abs="$(cd "$base_dir" && pwd -P)"
output_dir_abs="$(cd "$(dirname -- "$output_file")" && pwd -P)"
output_file_abs="${output_dir_abs}/$(basename -- "$output_file")"

: > "$output_file_abs"
chmod 600 "$output_file_abs"

included=0
skipped_path=0
skipped_type=0
skipped_sensitive=0
skipped_size=0
skipped_binary=0
skipped_self=0

is_excluded_path() {
  local rel="$1"

  case "/$rel/" in
    */.git/*|\
    */.hoogle/*|\
    */dist-newstyle/*|\
    */dist/*|\
    */.stack-work/*|\
    */result/*|\
    */.direnv/*|\
    */.cache/*|\
    */.tmp/*|\
    */tmp/*|\
    */.next/*|\
    */.turbo/*|\
    */node_modules/*|\
    */coverage/*|\
    */.nyc_output/*|\
    */.parcel-cache/*|\
    */.vite/*|\
    */.svelte-kit/*|\
    */.venv/*|\
    */venv/*|\
    */__pycache__/*|\
    */.mypy_cache/*|\
    */.pytest_cache/*|\
    */.ruff_cache/*|\
    */.tox/*|\
    */.idea/*|\
    */.vscode/*|\
    */dbReal/*|\
    */dbReal.bak-*/*|\
    */static.out/*)
      return 0
      ;;
  esac

  # Generated Node/Nix files that are usually very large and reproducible.
  case "$rel" in
    */node/node-packages.nix|\
    */node/node-env.nix)
      return 0
      ;;
  esac

  return 1
}

is_generated_output() {
  local name="$1"

  case "$name" in
    all_files_output.txt|\
    output.txt|\
    ob-out.txt|\
    ghcid-output.txt|\
    concat-output.txt|\
    concat-*.txt)
      return 0
      ;;
  esac

  return 1
}

is_sensitive_name() {
  local rel="$1"
  local name lower

  [ "$include_sensitive" -eq 1 ] && return 1

  name="$(basename -- "$rel")"
  lower="${name,,}"

  case "$lower" in
    .env|.env.*|\
    *secret*|\
    *password*|\
    *passwd*|\
    *apikey*|\
    *api_key*|\
    *access_token*|\
    *refresh_token*|\
    *private_key*|\
    *sessionkey*|\
    sendgridkey|\
    stripe_key|\
    gptapikey|\
    *.pem|\
    *.p12|\
    *.pfx|\
    *.key)
      return 0
      ;;
  esac

  # Known sensitive configuration files in this project.
  case "$rel" in
    config/backend/smtp.json|\
    config/backend/neo4j/password|\
    config/backend/neo4j/user|\
    config/backend/neo4j/host|\
    config/backend/neo4j/port|\
    config/backend/neo4j/database)
      return 0
      ;;
  esac

  return 1
}

is_allowed_text_type() {
  local name="$1"
  local lower="${name,,}"

  # Useful extensionless project files.
  case "$name" in
    README|LICENSE|COPYING|NOTICE|Makefile|Dockerfile)
      return 0
      ;;
  esac

  # Explicitly useful lock/config file.
  case "$name" in
    flake.lock)
      return 0
      ;;
  esac

  case "$lower" in
    *.hs|\
    *.lhs|\
    *.cabal|\
    *.nix|\
    *.md|\
    *.markdown|\
    *.org|\
    *.sh|\
    *.bash|\
    *.zsh|\
    *.fish|\
    *.yaml|\
    *.yml|\
    *.json|\
    *.csv|\
    *.html|\
    *.htm|\
    *.css|\
    *.scss|\
    *.sass|\
    *.less|\
    *.js|\
    *.jsx|\
    *.ts|\
    *.tsx|\
    *.mjs|\
    *.cjs|\
    *.toml|\
    *.ini|\
    *.conf|\
    *.cfg|\
    *.txt|\
    *.sql|\
    *.gql|\
    *.graphql|\
    *.proto|\
    *.agda|\
    *.dhall|\
    *.xml|\
    *.xsd|\
    *.xslt)
      return 0
      ;;
  esac

  return 1
}

is_text_file() {
  local path="$1"

  # Empty files are harmless text for our purposes.
  [ ! -s "$path" ] && return 0

  # grep -I treats files containing NUL bytes as binary.
  LC_ALL=C grep -Iq '' "$path"
}

emit_candidates_git() {
  git -C "$base_dir_abs" ls-files -co --exclude-standard -z
}

emit_candidates_find() {
  find "$base_dir_abs" \
    \( \
      -path '*/.git' -o \
      -path '*/.hoogle' -o \
      -path '*/dist-newstyle' -o \
      -path '*/dist' -o \
      -path '*/.stack-work' -o \
      -path '*/result' -o \
      -path '*/.direnv' -o \
      -path '*/.cache' -o \
      -path '*/.tmp' -o \
      -path '*/tmp' -o \
      -path '*/.next' -o \
      -path '*/.turbo' -o \
      -path '*/node_modules' -o \
      -path '*/coverage' -o \
      -path '*/.nyc_output' -o \
      -path '*/.parcel-cache' -o \
      -path '*/.vite' -o \
      -path '*/.svelte-kit' -o \
      -path '*/.venv' -o \
      -path '*/venv' -o \
      -path '*/__pycache__' -o \
      -path '*/.mypy_cache' -o \
      -path '*/.pytest_cache' -o \
      -path '*/.ruff_cache' -o \
      -path '*/.tox' -o \
      -path '*/.idea' -o \
      -path '*/.vscode' -o \
      -path '*/dbReal' -o \
      -path '*/dbReal.bak-*' -o \
      -path '*/static.out' \
    \) -prune -o \
    -type f -print0
}

process_candidate() {
  local candidate="$1"
  local filepath rel name size

  if [[ "$candidate" = /* ]]; then
    filepath="$candidate"
    rel="${candidate#"$base_dir_abs"/}"
  else
    rel="${candidate#./}"
    filepath="$base_dir_abs/$rel"
  fi

  # Ignore vanished files and non-regular files.
  [ -f "$filepath" ] || return 0

  if [ "$filepath" -ef "$output_file_abs" ] 2>/dev/null; then
    skipped_self=$((skipped_self + 1))
    return 0
  fi

  name="$(basename -- "$rel")"

  if is_excluded_path "$rel"; then
    skipped_path=$((skipped_path + 1))
    return 0
  fi

  if is_generated_output "$name"; then
    skipped_path=$((skipped_path + 1))
    return 0
  fi

  if is_sensitive_name "$rel"; then
    skipped_sensitive=$((skipped_sensitive + 1))
    return 0
  fi

  if ! is_allowed_text_type "$name"; then
    skipped_type=$((skipped_type + 1))
    return 0
  fi

  size="$(wc -c < "$filepath")"
  if [ "$size" -gt "$max_bytes" ]; then
    skipped_size=$((skipped_size + 1))
    return 0
  fi

  if ! is_text_file "$filepath"; then
    skipped_binary=$((skipped_binary + 1))
    return 0
  fi

  {
    printf '%s\n' "#####################################"
    printf '%s\n' "#"
    printf '#         %s\n' "$rel"
    printf '%s\n' "#"
    printf '%s\n' "#####################################"
    cat -- "$filepath"
    printf '\n\n'
  } >> "$output_file_abs"

  included=$((included + 1))
}

if [ "$use_git" -eq 1 ] && git -C "$base_dir_abs" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  enumeration="git"
  while IFS= read -r -d '' candidate; do
    process_candidate "$candidate"
  done < <(emit_candidates_git)
else
  enumeration="find"
  while IFS= read -r -d '' candidate; do
    process_candidate "$candidate"
  done < <(emit_candidates_find)
fi

printf 'Created: %s\n' "$output_file_abs" >&2
printf 'Enumeration: %s\n' "$enumeration" >&2
printf 'Included files: %d\n' "$included" >&2
printf 'Skipped by path/output rule: %d\n' "$skipped_path" >&2
printf 'Skipped by type allowlist: %d\n' "$skipped_type" >&2
printf 'Skipped as sensitive: %d\n' "$skipped_sensitive" >&2
printf 'Skipped over size limit: %d\n' "$skipped_size" >&2
printf 'Skipped as binary: %d\n' "$skipped_binary" >&2
printf 'Skipped output file itself: %d\n' "$skipped_self" >&2
