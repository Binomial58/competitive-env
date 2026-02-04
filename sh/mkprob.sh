#!/bin/bash

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

# フォルダ名・ファイル名は問題名そのまま
PROB="$FULL"


# 既存チェック
if [ -e "$PROB" ]; then
    echo "error: $PROB already exists."
    exit 1
fi

# ディレクトリ作成
mkdir "$PROB"

case "$LANG" in
    cpp)
        touch "$PROB/$PROB.cpp"
        touch "$PROB/in.txt"
        touch "$PROB/out.txt"

        if [ ! -f "$TEMPLATE_CPP" ]; then
            echo "error: template not found: $TEMPLATE_CPP"
            exit 1
        fi
        cp "$TEMPLATE_CPP" "$PROB/$PROB.cpp"
        echo "created C++ problem: $PROB (from $FULL)"
        ;;
    py)
        touch "$PROB/$PROB.py"
        echo "created Python problem: $PROB (from $FULL)"
        ;;
    *)
        echo "error: language must be 'cpp' or 'py'"
        exit 1
        ;;
esac
