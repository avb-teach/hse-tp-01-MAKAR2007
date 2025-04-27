#!/usr/bin/env python3.12
# обход директорий — https://docs.python.org/3/library/os.html#os.walk
# относительный путь и части — https://docs.python.org/3/library/pathlib.html#pathlib.Path.relative_to
# копирование с метаданными — https://docs.python.org/3/library/shutil.html#shutil.copy2
# уникальные имена (_1, _2…) — https://stackoverflow.com/a/15542070

import sys, os, shutil
from pathlib import Path

def main():
    if len(sys.argv) < 3:
        print(f"usage: {sys.argv[0]} <input_dir> <output_dir> [--max_depth N]", file=sys.stderr)
        sys.exit(1)

    inp = Path(sys.argv[1])
    out = Path(sys.argv[2])
    md = None
    if len(sys.argv) >= 5 and sys.argv[3] == "--max_depth":
        try:
            md = int(sys.argv[4])
        except:
            print("Error: --max_depth requires an integer", file=sys.stderr)
            sys.exit(1)
    if md is None:
        md = 1

    if not inp.is_dir():
        print("input dir not found", file=sys.stderr)
        sys.exit(1)
    out.mkdir(parents=True, exist_ok=True)

    for root, _, files in os.walk(inp):
        for name in files:
            src = Path(root) / name
            rel = src.relative_to(inp)
            parts = rel.parts
            if len(parts) > md:
                parts = parts[-md:]
            dest_dir = out.joinpath(*parts[:-1])
            dest_dir.mkdir(parents=True, exist_ok=True)
            fname = parts[-1]
            dst = dest_dir / fname
            base, ext = os.path.splitext(fname)
            i = 1
            while dst.exists():
                dst = dest_dir / f"{base}_{i}{ext}"
                i += 1
            shutil.copy2(src, dst)

if __name__ == "__main__":
    main()