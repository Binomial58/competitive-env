#!/bin/bash

# a.out の存在確認
if [ ! -f "./a.out" ]; then
    echo "error: a.out not found."
    exit 1
fi

# in.txt の存在確認
if [ ! -f "./in.txt" ]; then
    echo "error: in.txt not found."
    exit 1
fi

start=$(date +%s%3N)

if [ "$1" = "term" ]; then
    ./a.out < in.txt
else
    ./a.out < in.txt > out.txt
fi

end=$(date +%s%3N)
elapsed=$((end - start))

echo "[Time] ${elapsed} ms"
