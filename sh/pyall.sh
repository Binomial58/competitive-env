#!/bin/bash

# 対象ファイル名
NAME="$1"

# 引数なし → main.py
if [ -z "$NAME" ]; then
    PY_FILE="main.py"
else
    # .py が付いていたら外す
    NAME="${NAME%.py}"
    PY_FILE="$NAME.py"
fi

SAMPLE_DIR="samples"

if [ ! -f "$PY_FILE" ]; then
    echo "error: $PY_FILE not found."
    exit 1
fi

if [ ! -d "$SAMPLE_DIR" ]; then
    echo "error: samples directory not found."
    exit 1
fi

shopt -s nullglob
OK_ALL=true

for infile in "$SAMPLE_DIR"/*.in; do
    base="$(basename "${infile%.in}")"
    outfile="$SAMPLE_DIR/$base.out"
    tmpfile="$SAMPLE_DIR/$base.tmp"

    python3 "$PY_FILE" < "$infile" > "$tmpfile"

    if diff -u "$outfile" "$tmpfile" > /dev/null; then
        echo "[OK]   $base"
    else
        echo "[NG]   $base"
        diff -u "$outfile" "$tmpfile"
        OK_ALL=false
    fi

    rm "$tmpfile"
done

if $OK_ALL; then
    echo "=== ALL PYTHON SAMPLES PASSED ==="
else
    echo "=== SOME PYTHON SAMPLES FAILED ==="
fi
