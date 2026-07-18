#!/bin/bash

# io / ioall / pyall.sh で共通の出力比較・サンプル解決・TL 解決ロジック。
# resolve_sample_input は呼び出し元が SAMPLE_DIR を設定している前提。

normalize_output() {
    local file="$1"

    LC_ALL=C perl -0777 -pe '
        s/[\t\r ]+(?=\n|\z)//g;
        s/\n*\z//;
        $_ .= "\n" if length;
    ' "$file"
}

outputs_match() {
    local expected="$1"
    local actual="$2"

    if cmp -s "$expected" "$actual"; then
        return 0
    fi

    cmp -s <(normalize_output "$expected") <(normalize_output "$actual")
}

resolve_sample_input() {
    local idx="$1"
    if [ ! -d "$SAMPLE_DIR" ]; then
        return 1
    fi

    if [ -f "$SAMPLE_DIR/sample-${idx}.in" ]; then
        echo "$SAMPLE_DIR/sample-${idx}.in"
        return 0
    fi

    local infile base suffix
    for infile in "$SAMPLE_DIR"/*.in; do
        base="$(basename "${infile%.in}")"
        if [[ "$base" =~ -([0-9]+)$ ]]; then
            suffix="${BASH_REMATCH[1]}"
            if [ $((10#$suffix)) -eq $((10#$idx)) ]; then
                echo "$infile"
                return 0
            fi
        fi
    done
    return 1
}

# AtCoder の標準的な制限時間。tl.txt も --tl も無い問題はこれを使う。
# 別の値をデフォルトにしたければ環境変数 DEFAULT_TL_MS で上書きできる。
DEFAULT_TL_MS="${DEFAULT_TL_MS:-2000}"

# 実行時間制限(ms)を解決する。優先順位:
#   1) TL_MS 環境変数(--tl オプションでその場限り指定)
#   2) ./tl.txt (問題ごとに制限時間が違う場合の個別指定)
#   3) DEFAULT_TL_MS (通常は 2000ms)
resolve_time_limit() {
    if [ -n "${TL_MS:-}" ] && [[ "$TL_MS" =~ ^[0-9]+$ ]]; then
        echo "$TL_MS"
        return 0
    fi

    if [ -f "tl.txt" ]; then
        local v
        v="$(tr -dc '0-9' < tl.txt)"
        if [ -n "$v" ]; then
            echo "$v"
            return 0
        fi
    fi

    echo "$DEFAULT_TL_MS"
    return 0
}
