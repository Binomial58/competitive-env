# 前提ディレクトリ構成

（※ 以下は表示用の例であり，``` はコメントアウトしている）

 ```text
 ~/competitive/
 └── sh/
     ├── build.sh    （bd）
     ├── io.sh       （io / io term）
     ├── ioall.sh    （C++ 全サンプル実行）
     ├── pyall.sh    （Python 全サンプル実行）
     └── mkprob.sh   （問題テンプレ生成）
 ```

---

# mkprob：問題テンプレ生成

## 概要

問題用のディレクトリを自動生成するコマンドである．  
C++ または Python を選択できる．  
フォルダ名は問題名の最後の文字（a / b / c …）になる．

---

## 仕様

- フォルダ名：`abc365_a` → `a`
- ファイル名：フォルダ名と同一
- C++ の場合は初期コードが自動で書き込まれる
- Python の場合は空ファイルを生成する
- `samples/` ディレクトリを同時に生成する

---

## 使い方

 ```bash
 mkprob cpp abc365_a
 ```

生成される構成：

 ```text
 a/
 ├── a.cpp
 ├── in.txt
 ├── out.txt
 └── samples/
 ```

 ```bash
 mkprob py abc365_b
 ```

生成される構成：

 ```text
 b/
 ├── b.py
 └── samples/
 ```

---

# bd：C++ コンパイル

# 概要

指定した C++ ファイルをコンパイルし，`a.out` を生成する．

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

---

## 使い方

 ```bash
 io
 ```

 ```bash
 io term
 ```

 ```bash
 io sample
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
