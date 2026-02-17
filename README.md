# competitive-env

競技プログラミング用のローカルコマンド集。  
C++/Python のビルド・実行・サンプル検証を短いコマンドで行う。

---

# 前提ディレクトリ構成

```text
~/competitive-env/
└── sh/
    ├── build.sh    （bd）
    ├── io.sh       （io / io term）
    ├── ioall       （C++ 全サンプル実行）
    ├── py          （Python 単体/番号実行）
    ├── pyall.sh    （Python 全サンプル実行）
    ├── pyrun       （Python 単体実行）
    ├── run         （自動判別で単体実行）
    ├── runall      （自動判別で全サンプル実行）
    └── mkprob.sh   （問題テンプレ生成）
```

`.zshrc` で PATH を通して使う想定。

---

# 主要コマンド（C++ / Python）

## 自動ファイル判定のルール

引数なしのときは以下の順で自動判定する。

1) **現在のフォルダ名と同名の `*.cpp` / `*.py` があればそれを使う**  
2) なければ **`*.cpp` / `*.py` が1つだけある場合はそれを使う**  
3) それ以外はエラー（明示的にファイル名を指定）

---

## run：単体実行（C++ / Python）

概要:
- C++: `build.sh` → `io term`
- Python: `python3` で直接実行

例:
```bash
run
run a
run a.cpp
run a.py
```

---

## runall：全サンプル実行（C++ / Python）

概要:
- C++: `build.sh` → `ioall`
- Python: `pyall`
- すべて通過したら **ソースを自動コピー**

例:
```bash
runall
runall a
runall a.cpp
runall a.py
```

---

## run：サンプル番号指定実行

概要:
- `samples/` の `sample-<番号>.in/.out` を1件だけ検証
- 該当サンプルが無い場合は `in.txt` を使う（`out.txt` があれば比較）
- 自動判定は run/runall と同じ
- 実行時は **入力 → 空行 → 出力** の順に表示される

例:
```bash
run 0
run 5
run --sample 5
```

---

## pyall：Python 全サンプル一括実行

概要:
- `samples/` の `.in/.out` を全実行
- 実行時間を ms 表示
- すべて通過したら **ソースを自動コピー**
- NG の diff を `failures/` に保存
- `--clean` で `failures/` を削除
- 全サンプル OK のときは `failures/` を自動削除

例:
```bash
pyall
pyall a
pyall abc439_a
pyall --clean
pyall --clean abc439_a
```

---

## ioall：C++ 全サンプル一括実行

概要:
- `samples/` の `.in/.out` を全実行
- 実行時間を ms 表示
- NG の diff を `failures/` に保存
- `--clean` で `failures/` を削除
- 全サンプル OK のときは `failures/` を自動削除

例:
```bash
ioall
ioall --clean
```

---

## pyrun：Python 単体実行（stdin はターミナル貼り付け）

概要:
- `python3` をそのまま実行
- 入力はターミナルに貼り付ける運用向け
- 自動判定は run/runall と同じ

例:
```bash
pyrun
pyrun a
pyrun a.py
```

---

## py：Python 実行（単体 / サンプル番号指定）

概要:
- `py` / `py a` は `pyrun` と同様に Python 単体実行
- `samples/` の `sample-<番号>.in/.out` を1件だけ検証
- 該当サンプルが無い場合は `in.txt` を使う（`out.txt` があれば比較）
- 実行時は **入力 → 空行 → 出力** の順に表示される

例:
```bash
py
py a
py 1
py 5
py --sample 5 a
```

---

## cleanfail：failures/ を削除

```bash
cleanfail
```

---

# mkprob：問題テンプレ生成

## 概要

問題用のディレクトリを自動生成する。  
C++ または Python を選択できる。

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

## 概要

指定した C++ ファイルをコンパイルし `a.out` を生成する。  
`atcoder` が含まれる場合は `./ac-library` を include する。  
`gmpxx.h` が含まれる場合は `-lgmpxx -lgmp` を付与する。  
`debug` 指定時は sanitizer を有効化する。

---

## 使い方

```bash
bd a
bd
bd a debug
```

---

# io：単一入力の実行

## 概要

`in.txt` を標準入力として `a.out` を実行する。  
デフォルトは `out.txt` に出力し、`term` 指定時は標準出力に表示する。  
`term` のときは **入力 → 空行 → 出力** の順に表示される。

---

## 使い方

```bash
io
io term
```

---

# C++ テンプレ：Graph（無向・重み無し）

`templates/cpp_template.cpp` には無向・重み無しの `Graph` 構造体を用意してある。  
隣接リストは `vector<vector<int>>` で保持する。

例:
```cpp
Graph G(n);
G.add_edge(u, v);   // 無向（デフォルト）
for (int to : G[u]) {
    // ...
}
```

---

# トラブルシューティング

- **`main.cpp` / `main.py` が見つからない**
  - 引数なし実行時の自動判定が失敗している。  
    フォルダ名と同名のファイルが無い or 複数ファイルがある場合は  
    `run a` / `runall a` / `pyall a` のように明示指定する。
- **コピーされない**
  - `xclip` が必要。無い場合は警告を出してコピーをスキップする。
