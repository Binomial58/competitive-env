# competitive-env

競技プログラミング用のローカルコマンド集。  
C++/Python のビルド・実行・サンプル検証を短いコマンドで行う。

---

# 前提ディレクトリ構成

```text
~/competitive-env/
└── sh/
    ├── build.sh          （bd）
    ├── io.sh             （io / io term）
    ├── ioall             （C++ 全サンプル実行）
    ├── py                （Python 単体/番号実行）
    ├── pyall.sh          （Python 全サンプル実行）
    ├── pyrun             （Python 単体実行）
    ├── run               （自動判別で単体実行）
    ├── runi              （自動判別で対話実行）
    ├── runall            （自動判別で全サンプル実行）
    ├── mkprob.sh         （問題テンプレ生成: 1問）
    ├── mkcontest         （問題テンプレ生成: コンテスト単位で一括）
    ├── mkcontest.sh
    ├── resolve_target.sh （内部共有: run/runall/runi の対象ファイル自動判定）
    ├── io_compare.sh     （内部共有: ioall/pyall.sh の出力比較・サンプル解決）
    ├── mkprob_core.sh    （内部共有: mkprob.sh/mkcontest.sh の1問生成ロジック）
    └── cpp_re_report.sh  （内部共有: io/ioall の RE 原因レポート）
```

`resolve_target.sh` / `io_compare.sh` / `mkprob_core.sh` / `cpp_re_report.sh` はコマンドとして
直接実行するものではなく、上記スクリプトから `source` される共通関数ライブラリ。

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
- C++ が RE した場合は sanitizer 付き debug build で同じ入力を再実行し、原因候補・該当行を表示

例:
```bash
run
run a
run a.cpp
run a.py
run --debug
```

---

## runi：対話実行（C++ / Python）

概要:
- C++: `build.sh` → `./a.out` を直接実行
- Python: `python3` で直接実行
- `in.txt` は使わず、標準入力をターミナルにつないだままにする
- `run --interactive` でも同じ実行になる

例:
```bash
runi
runi a
runi a.cpp
runi a.py
runi --debug
run --interactive a
```

インタラクティブ問題では、出力ごとに `cout << x << endl;` または `cout << x << '\n' << flush;` のように flush する。

---

## runall：全サンプル実行（C++ / Python）

概要:
- C++: `build.sh` → `ioall`
- Python: `pyall`
- AtCoder と同様に、各行末の空白とファイル末尾の改行・空行の差を無視して比較する
- すべて通過したら **ソースを自動コピー**
- C++ が RE した場合は sanitizer 付き debug build で同じ入力を再実行し、原因候補・該当行を表示

例:
```bash
runall
runall a
runall a.cpp
runall a.py
runall --debug
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
run --debug 0
```

---

## pyall：Python 全サンプル一括実行

概要:
- `samples/` の `.in/.out` を全実行
- 各行末の空白とファイル末尾の改行・空行の差を無視して比較
- 実行時間を ms 表示
- すべて通過したら **ソースを自動コピー**
- NG の diff を `failures/` に保存
- `--clean` で `failures/` を削除
- 全サンプル OK のときは `failures/` を自動削除
- `--sample N` でサンプル1件だけ実行（オプションと対象名はどちらを先に書いても良い）

例:
```bash
pyall
pyall a
pyall abc439_a
pyall --clean
pyall --clean abc439_a
pyall --sample 5 a
pyall a --sample 5
```

---

## ioall：C++ 全サンプル一括実行

概要:
- `samples/` の `.in/.out` を全実行
- 各行末の空白とファイル末尾の改行・空行の差を無視して比較
- 実行時間を ms 表示
- NG の diff を `failures/` に保存
- `--clean` で `failures/` を削除
- 全サンプル OK のときは `failures/` を自動削除
- `run` / `runall` 経由の C++ RE は debug build で自動再実行される
- 直接使う場合も `ioall --debug-source a` のように source 名を渡すと同じ診断を出せる

例:
```bash
ioall
ioall --clean
ioall --debug-source a
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

# mkcontest：コンテスト単位で問題を一括生成

## 概要

`mkprob` はそのまま（過去問を1問だけ解くときに使う）、  
コンテスト本番で複数問まとめて用意したいときは `mkcontest` を使う。  
内部的には `mkprob` と同じ生成ロジック（`sh/mkprob_core.sh`）を問題数ぶん繰り返し呼ぶだけ。

---

## 仕様

- フォルダ名：`<contest_prefix>_<suffix>`（`mkprob` と同じ命名規則の兄弟フォルダ）
- 個数指定 or サフィックス直接指定のどちらかを選べる
  - 個数指定（1〜26の整数1つ）: `a` から順に `<count>` 問ぶん生成
  - サフィックス直接指定（2つ以上、または数字以外を含む）: 指定した順にそのまま生成
- 既に存在するフォルダはスキップし、他のフォルダの生成は継続する
  - 1件でもスキップがあれば最後に一覧を表示し、終了コード 1 を返す

---

## 使い方

```bash
mkcontest cpp abc468 7        # abc468_a 〜 abc468_g を作成
mkcontest cpp abc468 a b c ex # abc468_a / abc468_b / abc468_c / abc468_ex を作成
mkcontest py arc199 6         # arc199_a 〜 arc199_f を作成
```

生成される構成（`mkcontest cpp abc468 7` の場合）：
```text
abc468_a/
├── abc468_a.cpp
├── in.txt
└── out.txt
abc468_b/
├── abc468_b.cpp
├── in.txt
└── out.txt
...(abc468_g まで同様)
```

---

# bd：C++ コンパイル

## 概要

指定した C++ ファイルをコンパイルし `a.out` を生成する。  
`atcoder` が含まれる場合は `./ac-library` を include する。  
`gmpxx.h` が含まれる場合は `-lgmpxx -lgmp` を付与する。  
`debug` 指定時は sanitizer、`_GLIBCXX_DEBUG`、デバッグ情報を有効化する。  
`trace` 指定時は sanitizer とデバッグ情報を有効化し、ユーザーコードの行番号特定を優先する。  
debug build の出力先は通常 `a.out`、`CPP_OUT=./a.debug.out bd a debug` のように環境変数で変更できる。

---

## 使い方

```bash
bd a
bd
bd a debug
bd a trace
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

# C++ テンプレ：Graph（重みなし / 重み付き）

`templates/cpp_template.cpp` には次の2種類を用意してある。

- `Graph`（重みなし）: `vector<vector<int>>`
- `WeightedGraph<W>`（重み付き）: `vector<vector<Edge>>` (`Edge{to, w}`)

例（重みなし）:
```cpp
Graph G(n);
G.add_edge(u, v);        // 無向（デフォルト）
G.add_edge(u, v, false); // 有向
for (int to : G[u]) {
    // ...
}
```

例（重み付き）:
```cpp
WeightedGraph<ll> WG(n);
WG.add_edge(u, v, cost);        // 無向（デフォルト）
WG.add_edge(u, v, cost, false); // 有向
for (auto e : WG[u]) {
    // e.to, e.w
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
- **`Segmentation fault` / `[RE]` の原因が分からない**
  - `run 0` / `runall` 経由なら RE 時に debug build で自動再実行する。  
    `配列・vector などの範囲外アクセス`, `0除算`, `符号付き整数オーバーフロー`, `nullptr 参照` などは原因候補として表示される。
  - 行番号が debug build だけで取れない場合は trace build でもう一度走らせ、`location:` と該当コード行を表示する。
  - 次回実行で RE が消えた場合は `failures/*.err`, `a.debug.out`, `a.trace.out` を自動削除する。
  - 最初から範囲チェック付きで走らせたい場合は `run --debug 0` / `runall --debug` を使う。
