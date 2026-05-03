#!/bin/bash

cpp_re_export_sanitizer_options() {
    export ASAN_OPTIONS="${ASAN_OPTIONS:-detect_leaks=0:halt_on_error=1}"
    export UBSAN_OPTIONS="${UBSAN_OPTIONS:-print_stacktrace=1:halt_on_error=1}"
}

cpp_re_describe_status() {
    local status="$1"

    case "$status" in
        134) echo "abort/assert/_GLIBCXX_DEBUG による停止の可能性" ;;
        136) echo "0除算などの算術例外(SIGFPE)の可能性" ;;
        137) echo "メモリ超過や外部 kill の可能性" ;;
        139) echo "Segmentation fault: 範囲外アクセス、nullptr、破壊済みメモリ参照などの可能性" ;;
        *) echo "終了コード $status で停止" ;;
    esac
}

cpp_re_describe_error() {
    local status="$1"
    local errfile="$2"

    if [ -s "$errfile" ]; then
        if grep -Eiq "attempt to subscript container with out-of-bounds index|subscript.*out-of-bounds|index .* out of bounds|container-overflow|AddressSanitizer: .*buffer-overflow" "$errfile"; then
            echo "配列・vector などの範囲外アクセスの可能性"
            return
        fi
        if grep -Eiq "heap-use-after-free|stack-use-after-return|stack-use-after-scope|use-after-poison" "$errfile"; then
            echo "解放後/寿命切れメモリへのアクセスの可能性"
            return
        fi
        if grep -Eiq "signed integer overflow" "$errfile"; then
            echo "符号付き整数オーバーフロー"
            return
        fi
        if grep -Eiq "division by zero|division-by-zero" "$errfile"; then
            echo "0除算"
            return
        fi
        if grep -Eiq "load of null pointer|store to null pointer|null pointer" "$errfile"; then
            echo "nullptr 参照の可能性"
            return
        fi
        if grep -Eiq "std::out_of_range|out_of_range" "$errfile"; then
            echo "out_of_range 例外: 範囲外アクセスや存在しない要素取得の可能性"
            return
        fi
        if grep -Eiq "std::bad_alloc|bad_alloc" "$errfile"; then
            echo "メモリ確保失敗の可能性"
            return
        fi
        if grep -Eiq "AddressSanitizer:DEADLYSIGNAL|Segmentation fault" "$errfile"; then
            echo "Segmentation fault: 範囲外アクセス、nullptr、破壊済みメモリ参照などの可能性"
            return
        fi
    fi

    cpp_re_describe_status "$status"
}

cpp_re_filtered_stderr_has_content() {
    local errfile="$1"
    sed '/^[^:][^:]*: line [0-9][0-9]*:.*(core dumped)/d' "$errfile" | grep -q .
}

cpp_re_print_filtered_stderr() {
    local errfile="$1"
    sed '/^[^:][^:]*: line [0-9][0-9]*:.*(core dumped)/d' "$errfile" | sed 's/^/    /'
}

cpp_re_extract_location() {
    local errfile="$1"
    local source="${2:-}"
    local source_base=""

    if [ -n "$source" ]; then
        source_base="${source##*/}"
        source_base="${source_base%.cpp}.cpp"
    fi

    awk -v base="$source_base" '
        {
            line = $0
            while (match(line, /[^[:space:]()]+\.cpp:[0-9]+(:[0-9]+)?/)) {
                loc = substr(line, RSTART, RLENGTH)
                file = loc
                sub(/:[0-9]+(:[0-9]+)?$/, "", file)
                name = file
                sub(/^.*\//, "", name)

                if (base == "" || name == base) {
                    print loc
                    found = 1
                    exit
                }
                if (fallback == "" && file !~ /^\/usr\// && file !~ /^\/lib\//) {
                    fallback = loc
                }

                line = substr(line, RSTART + RLENGTH)
            }
        }
        END {
            if (!found && fallback != "") {
                print fallback
            }
        }
    ' "$errfile"
}

cpp_re_print_source_snippet() {
    local location="$1"
    local source="${2:-}"
    local file line start end current text

    file="${location%%:*}"
    line="${location#*:}"
    line="${line%%:*}"

    if [ ! -f "$file" ] && [ -n "$source" ]; then
        file="${source%.cpp}.cpp"
    fi
    if [ ! -f "$file" ] || ! [[ "$line" =~ ^[0-9]+$ ]]; then
        return 1
    fi

    start=$((line - 2))
    if [ "$start" -lt 1 ]; then
        start=1
    fi
    end=$((line + 2))

    echo "  code:"
    current="$start"
    sed -n "${start},${end}p" "$file" | while IFS= read -r text; do
        if [ "$current" -eq "$line" ]; then
            printf '    > %4d | %s\n' "$current" "$text"
        else
            printf '      %4d | %s\n' "$current" "$text"
        fi
        current=$((current + 1))
    done
}

cpp_re_print_location() {
    local errfile="$1"
    local source="${2:-}"
    local location

    location="$(cpp_re_extract_location "$errfile" "$source")"
    if [ -z "$location" ]; then
        return 1
    fi

    echo "  location: $location"
    cpp_re_print_source_snippet "$location" "$source" || true
}

cpp_re_print_compact_report() {
    local status="$1"
    local errfile="$2"
    local source="${3:-}"

    echo "  cause: $(cpp_re_describe_error "$status" "$errfile")"
    cpp_re_print_location "$errfile" "$source" || echo "  location: 取得できませんでした"
}

cpp_re_print_report() {
    local status="$1"
    local errfile="$2"
    local source="${3:-}"

    echo "  cause: $(cpp_re_describe_error "$status" "$errfile")"
    cpp_re_print_location "$errfile" "$source" || true
    if cpp_re_filtered_stderr_has_content "$errfile"; then
        echo "  stderr:"
        cpp_re_print_filtered_stderr "$errfile"
    fi
}
