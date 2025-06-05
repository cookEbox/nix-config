#!/usr/bin/env bash

echo "Top 30 largest /nix/store items with roots:"
echo "--------------------------------------------"

find /nix/store -maxdepth 1 -type d -exec du -sh {} + 2>/dev/null \
  | sort -h | tail -n 30 \
  | awk '{print $2}' \
  | while read -r path; do
      echo "▶ $path"
      roots=$(nix-store --query --roots "$path")
      if [ -z "$roots" ]; then
        echo "    (no roots)"
      else
        echo "$roots" | sed 's/^/    /'
      fi
      echo
    done

