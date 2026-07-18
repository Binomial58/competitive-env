#!/bin/bash
set -euo pipefail

# 使い方チェック
if [ $# -lt 2 ]; then
    echo "usage: mkprob <cpp|py> <problem_name>"
    echo "example: mkprob cpp abc365_a"
    exit 1
fi

LANG="$1"
FULL="$2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_CPP="$SCRIPT_DIR/../templates/cpp_template.cpp"

. "$SCRIPT_DIR/mkprob_core.sh"

mkprob_create_one "$LANG" "$FULL" "$TEMPLATE_CPP"
