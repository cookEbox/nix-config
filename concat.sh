#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  concat [OPTIONS]
  concat [OUTPUT_DIR] [SCAN_ROOT]

Concatenate all (non-ignored) files under SCAN_ROOT into a single output file.

Options:
  -s, --source DIR        Root directory to scan (default: .)
  -t, --target DIR        Output directory (default: .)
      --output-dir DIR    Alias for --target
  -o, --output NAME       Output filename within target dir (default: all_files_output.txt)
      --output-file NAME  Alias for --output
  -h, --help              Show this help and exit

Outputs:
  TARGET_DIR/OUTPUT

Examples:
  concat --source /path/to/project --target /tmp --output project.txt
  concat -s . -t /tmp -o all_files_output.txt

Backwards-compatible positional usage:
  concat . /path/to/project
  concat /tmp .
EOF
}

# Requested behaviour: if invoked without args, show help.
if [ "$#" -eq 0 ]; then
  usage
  exit 0
fi

# Defaults
output_dir="."
base_dir="."
output_name="all_files_output.txt"

# Parse flags
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
      # Stop flag parsing; remaining args treated as positional.
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

# Normalise output_dir so "/" isn't duplicated.
output_dir="${output_dir%/}"
output_file="${output_dir}/${output_name}"

# Ensure parent dir exists even if output_name includes subdirs.
mkdir -p "$(dirname -- "$output_file")"
: > "$output_file"  # Clear output file if it exists

# Find all files, skipping VCS/build dirs and all image/media/archive formats
while IFS= read -r -d '' filepath; do
  # Skip the output file itself if it's under base_dir
  if [ "$filepath" -ef "$output_file" ] 2>/dev/null; then
    continue
  fi

  {
    echo "#####################################"
    echo "#"
    echo "#         $filepath"
    echo "#"
    echo "#####################################"
    cat "$filepath"
    echo
    echo
  } >> "$output_file"
done < <(
  find "$base_dir" \
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
      -path '*/.DS_Store' \
    \) -prune -o \
    -type f ! \( \
      -iname '*.png'  -o \
      -iname '*.jpg'  -o \
      -iname '*.jpeg' -o \
      -iname '*.gif'  -o \
      -iname '*.bmp'  -o \
      -iname '*.tiff' -o \
      -iname '*.tif'  -o \
      -iname '*.webp' -o \
      -iname '*.svg'  -o \
      -iname '*.ico'  -o \
      -iname '*.heic' -o \
      -iname '*.mp3'  -o \
      -iname '*.mp4'  -o \
      -iname '*.m4a'  -o \
      -iname '*.wav'  -o \
      -iname '*.flac' -o \
      -iname '*.ogg'  -o \
      -iname '*.webm' -o \
      -iname '*.mov'  -o \
      -iname '*.mkv'  -o \
      -iname '*.avi'  -o \
      -iname '*.pdf'  -o \
      -iname '*.zip'  -o \
      -iname '*.tar'  -o \
      -iname '*.gz'   -o \
      -iname '*.tgz'  -o \
      -iname '*.bz2'  -o \
      -iname '*.xz'   -o \
      -iname '*.7z'   -o \
      -iname '*.dmg'  -o \
      -iname '*.iso'  -o \
      -iname '*.lock' -o \
      -iname 'package-lock.json' -o \
      -iname 'pnpm-lock.yaml' -o \
      -iname 'yarn.lock' -o \
      -iname 'Cargo.lock' -o \
      -iname 'Gemfile.lock' -o \
      -iname 'composer.lock' -o \
      -iname '*.min.js' -o \
      -iname '*.min.css' -o \
      -iname '*.map' -o \
      -iname '*.log' -o \
      -iname '*.tmp' -o \
      -iname '*.swp' -o \
      -iname '*.swo' -o \
      -iname '*~' \
    \) -print0
)
