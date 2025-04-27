#!/bin/bash
set -e

if [[ $# -lt 2 ]]; then
  echo "usage: $0 <input_dir> <output_dir> [--max_depth N]" >&2
  exit 1
fi

IN="$1"
OUT="$2"
shift 2

MAX=""
if [[ $# -ge 2 && "$1" == "--max_depth" ]]; then
  MAX="$2"
fi

[[ -d "$IN" ]] || { echo "input dir not found" >&2; exit 1; }
mkdir -p "$OUT"

while IFS= read -r -d '' f; do
  rel="${f#$IN/}"
  dir=$(dirname "$rel")
  base=$(basename "$rel")

  if [[ -n "$MAX" ]]; then
    IFS='/' read -ra parts <<< "$dir"
    dir=""
    for ((i=0; i<${#parts[@]} && i<MAX; i++)); do
      [[ -n "${parts[i]}" ]] && dir="$dir/${parts[i]}"
    done
  else
    dir=""
  fi

  dest_dir="$OUT$dir"
  mkdir -p "$dest_dir"
  dest="$dest_dir/$base"

  if [[ -e "$dest" ]]; then
    ext="${base##*.}"
    name="${base%.*}"
    [[ "$ext" == "$base" ]] && { name="$base"; ext=""; }
    idx=1
    while : ; do
      [[ -z "$ext" ]] && try="${name}_${idx}" || try="${name}_${idx}.${ext}"
      dest="$dest_dir/$try"
      [[ ! -e "$dest" ]] && break
      ((idx++))
    done
  fi

  mv "$f" "$dest"
done < <(find "$IN" -type f -print0)