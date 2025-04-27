#!/bin/bash
set -e

if [ $# -lt 2 ]; then
  echo "usage: $0 <input_dir> <output_dir> [--max_depth N]" >&2
  exit 1
fi

IN="$1"
OUT="$2"
shift 2

MAX=""
if [ $# -ge 2 ] && [ "$1" = "--max_depth" ]; then
  MAX="$2"
fi

[ -d "$IN" ] || { echo "input dir not found" >&2; exit 1; }
mkdir -p "$OUT"

find "$IN" -type f -print0 | while IFS= read -r -d '' f; do
  rel="${f#$IN/}"
  base=$(basename "$rel")

  dir=""
  if [ -n "$MAX" ]; then
    pathdir=$(dirname "$rel")
    if [ "$pathdir" != "." ]; then
      IFS='/' read -ra parts <<< "$pathdir"
      for ((i=0; i<MAX && i<${#parts[@]}; i++)); do
        part=${parts[$i]}
        [ -n "$part" ] && dir="$dir/$part"
      done
    fi
  fi

  dest_dir="$OUT$dir"
  mkdir -p "$dest_dir"
  dest="$dest_dir/$base"

  if [ -e "$dest" ]; then
    ext="${base##*.}"
    name="${base%.*}"
    [ "$ext" = "$base" ] && { name="$base"; ext=""; }
    n=1
    while [ -e "$dest_dir/${name}_${n}${ext:+.$ext}" ]; do
      n=$((n+1))
    done
    dest="$dest_dir/${name}_${n}${ext:+.$ext}"
  fi

  cp "$f" "$dest"
done