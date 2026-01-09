#!/bin/bash

# 使い方チェック
if [ $# -lt 2 ]; then
    echo "usage: mkprob <cpp|py> <problem_name>"
    echo "example: mkprob cpp abc365_a"
    exit 1
fi

LANG="$1"
FULL="$2"

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

        cat << 'EOF' > "$PROB/$PROB.cpp"
#include <bits/stdc++.h>
using namespace std;

/* utility : mathematical modulo (always non-negative) */
inline int mod(int k, int n)
{
    return (k % n + n) % n;
}

inline long long mod(long long k, long long n)
{
    return (k % n + n) % n;
}

int main() {
    
}
EOF
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
