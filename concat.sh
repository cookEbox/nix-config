#!/usr/bin/env bash

output_file="all_files_output.txt"
base_dir="${1:-.}"  # Default to current directory unless specified

> "$output_file"  # Clear output file if it exists

find "$base_dir" -type f | while IFS= read -r filepath; do
  echo "#####################################" >> "$output_file"
  echo "#" >> "$output_file"
  echo "#         $filepath" >> "$output_file"
  echo "#" >> "$output_file"
  echo "#####################################" >> "$output_file"
  cat "$filepath" >> "$output_file"
  echo -e "\n" >> "$output_file"
done

