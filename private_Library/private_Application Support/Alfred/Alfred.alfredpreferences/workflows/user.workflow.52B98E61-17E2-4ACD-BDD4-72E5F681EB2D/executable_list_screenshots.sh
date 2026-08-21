#!/bin/bash
set -euo pipefail

dir="${screenshot_folder:-$HOME/Desktop}"
dir="${dir/#\~/$HOME}"

find "$dir" -maxdepth 1 -type f \
  \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.heic' -o -iname '*.gif' -o -iname '*.tiff' \) \
  -exec stat -f '%m%t%N' {} + 2>/dev/null \
  | sort -t $'\t' -k1,1 -rn \
  | cut -f2- \
  | jq -R -s '
      split("\n") | map(select(length > 0)) |
      map({
        title: (split("/") | last),
        subtitle: .,
        arg: .,
        uid: .,
        icon: {path: .}
      }) |
      {items: .}
    '
