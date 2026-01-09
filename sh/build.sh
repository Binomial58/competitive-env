#!/bin/bash

SOURCE_FILE="${1:-main}.cpp"

ATCODER_COUNT=$(grep -o "atcoder" "$SOURCE_FILE" 2>/dev/null | wc -l)
GMP_COUNT=$(grep -o "gmpxx.h" "$SOURCE_FILE" 2>/dev/null | wc -l)

CXX_FLAGS="-std=gnu++20 -O2 -Wall -Wextra"
LINK_FLAGS=""

if [ "$2" = "debug" ]; then
    CXX_FLAGS+=" -fsanitize=address -fsanitize=undefined"
fi

if [ "$ATCODER_COUNT" -ge 1 ]; then
    CXX_FLAGS+=" -I./ac-library"
fi

if [ "$GMP_COUNT" -ge 1 ]; then
    LINK_FLAGS+=" -lgmpxx -lgmp"
fi

g++ $CXX_FLAGS "$SOURCE_FILE" $LINK_FLAGS
