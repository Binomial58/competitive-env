#!/bin/bash

# options
CLEAN=false
SAMPLE_ONLY=""
NAME=""
NO_DIFF=false

while [ $# -gt 0 ]; do
    case "$1" in
        --clean)
            CLEAN=true
            shift
            ;;
        --nodiff)
            NO_DIFF=true
            shift
            ;;
        --sample|--only|-s)
            shift
            SAMPLE_ONLY="$1"
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            NAME="$1"
            shift
            break
            ;;
    esac
done

if [ -z "$NAME" ] && [ $# -gt 0 ]; then
    NAME="$1"
fi

# 引数なし → main.py
if [ -z "$NAME" ]; then
    PY_FILE="main.py"
else
    # .py が付いていたら外す
    NAME="${NAME%.py}"
    PY_FILE="$NAME.py"
fi

SAMPLE_DIR="samples"
FAIL_DIR="failures"

if $CLEAN; then
    rm -rf "$FAIL_DIR"
fi

if [ ! -f "$PY_FILE" ]; then
    echo "error: $PY_FILE not found."
    exit 1
fi

shopt -s nullglob
OK_ALL=true
SINGLE=false

run_case() {
    local infile="$1"
    local outfile="$2"
    local label="$3"
    local tmpfile="$4"
    local difffile="$5"

    start=$(date +%s%3N)
    python3 "$PY_FILE" < "$infile" > "$tmpfile"
    end=$(date +%s%3N)
    elapsed=$((end - start))

    if $SINGLE; then
        cat "$infile"
        echo
        cat "$tmpfile"
    fi

    if [ -f "$outfile" ]; then
        if diff -u "$outfile" "$tmpfile" > /dev/null; then
            echo "[AC]   $label (${elapsed} ms)"
        else
            echo "[WA]   $label (${elapsed} ms)"
            mkdir -p "$FAIL_DIR"
            if $NO_DIFF; then
                diff -u "$outfile" "$tmpfile" > "$difffile"
            else
                diff -u "$outfile" "$tmpfile" | tee "$difffile"
            fi
            OK_ALL=false
        fi
    else
        echo "[RUN]  $label (${elapsed} ms)"
        if ! $SINGLE; then
            cat "$tmpfile"
        fi
    fi

    rm -f "$tmpfile"
}

if [ -n "$SAMPLE_ONLY" ]; then
    SINGLE=true
    sample_in=""

    if [ -d "$SAMPLE_DIR" ]; then
        if [ -f "$SAMPLE_DIR/sample-${SAMPLE_ONLY}.in" ]; then
            sample_in="$SAMPLE_DIR/sample-${SAMPLE_ONLY}.in"
        else
            matches=("$SAMPLE_DIR"/*-"$SAMPLE_ONLY".in)
            if [ "${#matches[@]}" -ge 1 ]; then
                sample_in="${matches[0]}"
            fi
        fi
    fi

    if [ -n "$sample_in" ]; then
        base="$(basename "${sample_in%.in}")"
        outfile="${sample_in%.in}.out"
        tmpfile="$SAMPLE_DIR/$base.tmp"
        difffile="$FAIL_DIR/$base.diff"
        run_case "$sample_in" "$outfile" "$base" "$tmpfile" "$difffile"
    else
        if [ ! -f "./in.txt" ]; then
            echo "error: sample $SAMPLE_ONLY not found and in.txt not found."
            exit 1
        fi
        run_case "in.txt" "out.txt" "in.txt" "in.tmp" "$FAIL_DIR/in.diff"
    fi
else
    if [ ! -d "$SAMPLE_DIR" ]; then
        echo "error: samples directory not found."
        exit 1
    fi

    for infile in "$SAMPLE_DIR"/*.in; do
        base="$(basename "${infile%.in}")"
        outfile="$SAMPLE_DIR/$base.out"
        tmpfile="$SAMPLE_DIR/$base.tmp"
        difffile="$FAIL_DIR/$base.diff"
        run_case "$infile" "$outfile" "$base" "$tmpfile" "$difffile"
    done
fi

if $OK_ALL; then
    if $SINGLE; then
        :
    else
        echo "=== 全サンプルAC ==="
        echo "=== コピーします ==="
        if command -v xclip >/dev/null 2>&1; then
            xclip -selection clipboard < "$PY_FILE"
            echo "[Copied] $PY_FILE"
        else
            echo "warning: xclip not found; not copied."
        fi
        if [ -d "$FAIL_DIR" ]; then
            rm -rf "$FAIL_DIR"
        fi
    fi
else
    if $SINGLE; then
        :
    else
        echo "=== 一部WA ==="
    fi
fi

if $OK_ALL; then
    exit 0
else
    exit 1
fi
