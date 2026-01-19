# 前提ディレクトリ構成
 ```text
 ~/competitive/
 └── sh/
     ├── build.sh    （bd）
     ├── io.sh       （io / io term）
     ├── ioall.sh    （C++ 全サンプル実行）
     ├── pyall.sh    （Python 全サンプル実行）
     ├── run         （自動判別で単体実行）
     ├── runall      （自動判別で全サンプル実行）
     └── mkprob.sh   （問題テンプレ生成）
 ```

---

# mkprob：問題テンプレ生成

## 概要

問題用のディレクトリを自動生成するコマンドである．  
C++ または Python を選択できる．  
フォルダ名は問題名そのままになる．

---

## 仕様

- フォルダ名：`abc365_a` → `abc365_a`
- ファイル名：`<問題名>.<cpp|py>`
- C++ の場合は初期コードが自動で書き込まれる
- C++ の場合は `in.txt` / `out.txt` を生成する
- Python の場合は空ファイルを生成する

---

## 使い方

 ```bash
 mkprob cpp abc365_a
 ```

生成される構成：

 ```text
 abc365_a/
 ├── abc365_a.cpp
 ├── in.txt
 ├── out.txt
 ```

 ```bash
 mkprob py abc365_b
 ```

生成される構成：

 ```text
 abc365_b/
 └── abc365_b.py
 ```

---

# bd：C++ コンパイル

# 概要

指定した C++ ファイルをコンパイルし，`a.out` を生成する．  
`atcoder` が含まれる場合は `./ac-library` を include する．  
`gmpxx.h` が含まれる場合は `-lgmpxx -lgmp` を付与する．  
`debug` 指定時は sanitizer を有効化する．

---

## 使い方

`a.cpp` をコンパイルする：

 ```bash
 bd a
 ```

`main.cpp` をコンパイルする：

 ```bash
 bd
 ```

デバッグオプション付きでコンパイルする：

 ```bash
 bd a debug
 ```

---

# io：単一入力の実行

## 概要

`in.txt` を標準入力として `a.out` を実行する．  
デフォルトは `out.txt` に出力し，`term` 指定時は標準出力に表示する．  
実行時間を ms 表示する．

---

## 使い方

 ```bash
 io
 ```

 ```bash
 io term
 ```

---

# ioall：C++ 全サンプル一括実行

## 概要

`samples/` ディレクトリ内の  
すべての `.in` / `.out` ペアを用いて検証を行う．

---

## 前提構成

 ```text
 samples/
 ├── sample-0.in
 ├── sample-0.out
 ├── sample-1.in
 ├── sample-1.out
 ```

---

## 使い方

 ```bash
 ioall
 ```

---

# pyall：Python 全サンプル一括実行

## 概要

Python プログラムを用いて  
`samples/` 内のすべてのサンプルを一括検証する．

---

## 使い方

 ```bash
 pyall
 ```

 ```bash
 pyall a
 ```

 ```bash
 pyall abc439_a
 ```

---

# run：単体実行（C++ / Python）

## 概要

引数の名前に応じて C++ / Python を判別して実行する．  
C++ の場合は `build.sh` の後に `io.sh term` を呼ぶ．  
Python の場合は `python3` で直接実行する．

## 使い方

 ```bash
 run a
 ```

 ```bash
 run a.cpp
 ```

 ```bash
 run a.py
 ```

---

# runall：全サンプル実行（C++ / Python）

## 概要

引数の名前に応じて C++ / Python を判別して全サンプルを実行する．  
C++ の場合は `build.sh` の後に `ioall.sh` を呼ぶ．  
Python の場合は `pyall.sh` を呼ぶ．

## 使い方

 ```bash
 runall a
 ```

 ```bash
 runall a.cpp
 ```

 ```bash
 runall a.py
 ```
