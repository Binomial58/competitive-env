#!/bin/bash

# mkprob.sh / mkcontest.sh 共通: 1問分の問題ディレクトリを生成する。
# 呼び出し元は set -e 前提でも安全なように、失敗時は exit ではなく return する。
mkprob_create_one() {
    local lang="$1"
    local prob="$2"
    local template_cpp="$3"

    case "$lang" in
        cpp|py) ;;
        *)
            echo "error: language must be 'cpp' or 'py'" >&2
            return 1
            ;;
    esac

    if [ -e "$prob" ]; then
        echo "error: $prob already exists." >&2
        return 1
    fi

    mkdir "$prob"

    case "$lang" in
        cpp)
            touch "$prob/$prob.cpp"
            touch "$prob/in.txt"
            touch "$prob/out.txt"
            if [ ! -f "$template_cpp" ]; then
                echo "error: template not found: $template_cpp" >&2
                return 1
            fi
            cp "$template_cpp" "$prob/$prob.cpp"
            echo "created C++ problem: $prob"
            ;;
        py)
            touch "$prob/$prob.py"
            echo "created Python problem: $prob"
            ;;
    esac
}
