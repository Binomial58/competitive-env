#!/bin/bash

# next/back で共有する、兄弟の問題フォルダを解決するロジック。
# mkcontest が作る <contest_prefix>/<contest_prefix>_<suffix>/ という
# ディレクトリ構成を前提にしている(親フォルダ名 = 問題フォルダの接頭辞)。

resolve_sibling_dir() {
    local direction="$1" # "next" または "back"

    local cur parent prefix cur_name
    cur="$(pwd)"
    parent="$(dirname "$cur")"
    cur_name="$(basename "$cur")"
    prefix="$(basename "$parent")"

    shopt -s nullglob
    local siblings=() d name
    for d in "$parent/${prefix}_"*/; do
        name="$(basename "$d")"
        siblings+=("$name")
    done
    shopt -u nullglob

    if [ "${#siblings[@]}" -eq 0 ]; then
        echo "error: no sibling problem folders (${prefix}_*) found in $parent." >&2
        return 1
    fi

    IFS=$'\n' siblings=($(printf '%s\n' "${siblings[@]}" | sort))
    unset IFS

    local idx=-1 i
    for i in "${!siblings[@]}"; do
        if [ "${siblings[$i]}" = "$cur_name" ]; then
            idx=$i
            break
        fi
    done

    if [ "$idx" -lt 0 ]; then
        echo "error: current directory '$cur_name' is not one of the sibling problem folders in $parent." >&2
        return 1
    fi

    local target_idx
    if [ "$direction" = "next" ]; then
        target_idx=$((idx + 1))
        if [ "$target_idx" -ge "${#siblings[@]}" ]; then
            echo "error: already at the last problem ($cur_name) in $parent." >&2
            return 1
        fi
    else
        target_idx=$((idx - 1))
        if [ "$target_idx" -lt 0 ]; then
            echo "error: already at the first problem ($cur_name) in $parent." >&2
            return 1
        fi
    fi

    echo "$parent/${siblings[$target_idx]}"
}
