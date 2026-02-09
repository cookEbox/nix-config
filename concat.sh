#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  concat [OUTPUT_DIR] [SCAN_ROOT]

Writes a concatenation of all (non-ignored) files under SCAN_ROOT into:
  OUTPUT_DIR/all_files_output.txt

Examples:
  concat . /path/to/project
  concat /tmp .
EOF
}

case "${1:-}" in
  -h|--help)
    usage
    exit 0
    ;;
esac

output_dir="${1:-.}"
base_dir="${2:-.}"

# Normalise output_dir so "/" isn't duplicated.
output_dir="${output_dir%/}"
output_file="${output_dir}/all_files_output.txt"

mkdir -p "$output_dir"
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
