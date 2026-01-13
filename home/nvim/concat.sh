#!/usr/bin/env bash
set -euo pipefail

output_file="all_files_output.txt"
base_dir="${1:-.}"  # Default to current directory unless specified

: > "$output_file"  # Clear output file if it exists

# Find all files, skipping .git, dist-newstyle, .dev-logs, .direnv
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
    -type d \( -name .git -o -name dist-newstyle -o -name .dev-logs -o -name .direnv \) -prune -o \
    -type f -print0
)


