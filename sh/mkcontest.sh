#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_CPP="$SCRIPT_DIR/../templates/cpp_template.cpp"

usage() {
    echo "usage: mkcontest <cpp|py> <contest_prefix> <count>" >&2
    echo "       mkcontest <cpp|py> <contest_prefix> <suffix1> [suffix2 ...]" >&2
    echo "example: mkcontest cpp abc468 7        # abc468_a .. abc468_g" >&2
    echo "         mkcontest cpp abc468 a b c ex # abc468_a abc468_b abc468_c abc468_ex" >&2
    exit 1
}

[ $# -ge 3 ] || usage

LANG="$1"
PREFIX="$2"
shift 2

case "$LANG" in
    cpp|py) ;;
    *)
        echo "error: language must be 'cpp' or 'py'" >&2
        exit 1
        ;;
esac

SUFFIXES=()
if [ $# -eq 1 ] && [[ "$1" =~ ^[0-9]+$ ]]; then
    COUNT="$1"
    if [ "$COUNT" -lt 1 ] || [ "$COUNT" -gt 26 ]; then
        echo "error: count must be 1..26 (a..z). for more, list suffixes explicitly." >&2
        exit 1
    fi
    for ((i = 0; i < COUNT; i++)); do
        SUFFIXES+=("$(printf "\\$(printf '%03o' $((97 + i)))")")
    done
else
    SUFFIXES=("$@")
fi

. "$SCRIPT_DIR/mkprob_core.sh"

# コンテスト単位の親フォルダにまとめる。既にあれば再利用(追加生成)する。
if [ -e "$PREFIX" ] && [ ! -d "$PREFIX" ]; then
    echo "error: $PREFIX exists and is not a directory." >&2
    exit 1
fi
mkdir -p "$PREFIX"
cd "$PREFIX"

CREATED=()
SKIPPED=()
for suffix in "${SUFFIXES[@]}"; do
    prob="${PREFIX}_${suffix}"
    if mkprob_create_one "$LANG" "$prob" "$TEMPLATE_CPP"; then
        CREATED+=("$prob")
    else
        SKIPPED+=("$prob")
    fi
done

echo "=== $PREFIX/ 配下に ${#CREATED[@]} 件作成, ${#SKIPPED[@]} 件スキップ ==="
if [ "${#SKIPPED[@]}" -gt 0 ]; then
    echo "skipped: ${SKIPPED[*]}" >&2
    exit 1
fi
