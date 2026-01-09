#!/bin/bash

PY_FILE="${1:-main}.py"
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

    start=$(date +%s%3N)
    python3 "$PY_FILE" < "$infile" > "$tmpfile"
    end=$(date +%s%3N)

    elapsed=$((end - start))

    if diff -u "$outfile" "$tmpfile" > /dev/null; then
        echo "[OK]   $base (${elapsed} ms)"
    else
        echo "[NG]   $base (${elapsed} ms)"
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
