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
  base=$(basename "$rel")

  dir=""
  if [ -n "$MAX" ]; then
    pdir=$(dirname "$rel")
    if [ "$pdir" != "." ]; then
      IFS='/' read -ra parts <<< "$pdir"
      for ((i=0; i<MAX && i<${#parts[@]}; i++)); do
        d=${parts[$i]}
        [ -n "$d" ] && dir="$dir/$d"
      done
    fi
  fi

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