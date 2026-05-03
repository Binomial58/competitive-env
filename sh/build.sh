#!/bin/bash

SOURCE_ARG="${1:-main}"
SOURCE_FILE="${SOURCE_ARG%.cpp}.cpp"
shift 2>/dev/null || true

MODE="release"
for arg in "$@"; do
    case "$arg" in
        debug|--debug)
            MODE="debug"
            ;;
        trace|--trace)
            MODE="trace"
            ;;
        *)
            echo "error: unknown build option: $arg" >&2
            exit 1
            ;;
    esac
done

ATCODER_COUNT=$(grep -o "atcoder" "$SOURCE_FILE" 2>/dev/null | wc -l)
GMP_COUNT=$(grep -o "gmpxx.h" "$SOURCE_FILE" 2>/dev/null | wc -l)

case "$MODE" in
    debug)
        CXX_FLAGS="-std=gnu++20 -O0 -g3 -Wall -Wextra -DLOCAL -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC"
        CXX_FLAGS+=" -fsanitize=address,undefined -fno-sanitize-recover=all -fno-omit-frame-pointer"
        ;;
    trace)
        CXX_FLAGS="-std=gnu++20 -O0 -g3 -Wall -Wextra -DLOCAL"
        CXX_FLAGS+=" -fsanitize=address,undefined -fno-sanitize-recover=all -fno-omit-frame-pointer"
        ;;
    *)
        CXX_FLAGS="-std=gnu++20 -O2 -Wall -Wextra"
        ;;
esac
LINK_FLAGS=""

if [ "$ATCODER_COUNT" -ge 1 ]; then
    CXX_FLAGS+=" -I./ac-library"
fi

if [ "$GMP_COUNT" -ge 1 ]; then
    LINK_FLAGS+=" -lgmpxx -lgmp"
fi

g++ $CXX_FLAGS "$SOURCE_FILE" $LINK_FLAGS -o "${CPP_OUT:-a.out}"
