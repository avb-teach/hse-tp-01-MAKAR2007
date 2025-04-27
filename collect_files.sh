#!/bin/bash
set -e

# find -print0 / read -d '' — https://www.gnu.org/software/findutils/manual/html_node/find_002dprint0.html
# IFS='/' read -a parts     — https://mywiki.wooledge.org/BashFAQ/005
# ${x%.*} и ${x##*.}        — https://tldp.org/LDP/abs/html/refcards.html
# суффикс _1 _2 …           — https://stackoverflow.com/a/15542070

if [ $# -lt 2 ]; then
  echo "usage: $0 <input> <output> [--max_depth N]"
  exit 1
fi

IN="$1"
OUT="$2"
shift 2

MAX=""
if [ $# -ge 2 ] && [ "$1" = "--max_depth" ]; then
  MAX="$2"
fi

[ -d "$IN" ] || { echo "input dir not found"; exit 1; }
mkdir -p "$OUT"

find "$IN" -type f -print0 | while IFS= read -r -d '' f; do
  rel="${f#$IN/}"
  IFS='/' read -ra parts <<< "$rel"
  [ -n "$MAX" ] || MAX=1
  len=${#parts[@]}
  if [ "$len" -gt "$MAX" ]; then
    start=$((len - MAX))
    newparts=( "${parts[@]:start:MAX}" )
  else
    newparts=( "${parts[@]}" )
  fi
  dst="$OUT"
  for ((i=0; i<${#newparts[@]}-1; i++)); do
    dst="$dst/${newparts[i]}"
  done
  mkdir -p "$dst"
  base="${newparts[-1]}"
  dst="$dst/$base"
  dst_dir="$OUT$dir"
  mkdir -p "$dst_dir"
  dst="$dst_dir/$base"

  if [ -e "$dst" ]; then
    ext="${base##*.}"
    name="${base%.*}"
    [ "$ext" = "$base" ] && { name="$base"; ext=""; }
    n=1
    while [ -e "$dst_dir/${name}_${n}${ext:+.$ext}" ]; do
      n=$((n+1))
    done
    dst="$dst_dir/${name}_${n}${ext:+.$ext}"
  fi

  cp "$f" "$dst"
done