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
    ├── mkprob.sh         （問題テンプレ生成）
    ├── stress            （ランダムテスト: gen/brute と main を自動比較）
    ├── stress.sh
    ├── resolve_target.sh （内部共有: run/runall/runi/stress の対象ファイル自動判定）
    ├── io_compare.sh     （内部共有: io/ioall/pyall.sh/stress の出力比較・サンプル解決・TL 解決）
    └── cpp_re_report.sh  （内部共有: io/ioall の RE 原因レポート）
```

`resolve_target.sh` / `io_compare.sh` / `cpp_re_report.sh` はコマンドとして直接実行するものではなく、
上記スクリプトから `source` される共通関数ライブラリ。

`.zshrc` で PATH を通して使う想定。

---

# 主要コマンド（C++ / Python）

## 自動ファイル判定のルール

引数なしのときは以下の順で自動判定する。

1) **現在のフォルダ名と同名の `*.cpp` / `*.py` があればそれを使う**  
2) なければ **`*.cpp` / `*.py` が1つだけある場合はそれを使う**  
3) それ以外はエラー（明示的にファイル名を指定）

---

## 実行時間制限（TLE 検出）

`run` / `runall` / `ioall` / `pyall` / `io` / `stress` は、実行時間が
制限を超えたら `[AC]`/`[RUN]` の代わりに `[TLE]` と表示し、失敗扱いにする。
**デフォルトは AtCoder の標準的な制限時間 2000ms** で、何も指定しなくても
常に判定される。

制限時間(ms)は次の優先順で解決される:

1) `--tl <ms>` オプション（明示指定、その場限り）
2) 問題フォルダ直下の `tl.txt`（1行に整数を書くだけ。制限時間が
   2000ms でない特殊な問題のときに使う）
3) どちらも無ければ既定値 2000ms

```bash
echo 3000 > tl.txt   # この問題だけ制限時間が 3000ms の場合
run --tl 3000        # その場限りで 3000ms 制限にする(tl.txt より優先)
```

既定値そのものを変えたい場合は環境変数 `DEFAULT_TL_MS` を設定する
（`.zshrc` などで `export DEFAULT_TL_MS=3000` のように）。

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
run --tl 2000
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
runall --tl 2000
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
- 実行時間制限は既定 2000ms。`--tl N` や `tl.txt` でこの問題だけ変更できる

例:
```bash
pyall
pyall a
pyall abc439_a
pyall --clean
pyall --clean abc439_a
pyall --sample 5 a
pyall a --sample 5
pyall --tl 2000 a
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
- 実行時間制限は既定 2000ms。`--tl N` や `tl.txt` でこの問題だけ変更できる

例:
```bash
ioall
ioall --clean
ioall --debug-source a
ioall --tl 2000
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
py --tl 2000 --sample 5 a
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

# stress：ランダムテスト（stress test）

## 概要

ランダムな入力を生成し、遅くても確実に正しい参照実装（brute force）と
本命の実装（main）の出力を自動で比較し続ける。一致しなくなった/main が
異常終了した/制限時間を超えた時点で止まり、再現用の入力を保存する。
WA の原因調査や、サンプルには出てこないコーナーケースの発見に使う。

---

## 仕様

カレントディレクトリに以下が必要:

- `gen.cpp` / `gen.py`：`argv[1]` にシード(整数)を受け取り、標準出力に
  ランダムな入力を1件出力するジェネレータ
- `brute.cpp` / `brute.py`：遅くても良いので確実に正しい参照実装
- 本命の実装（`main_source` を省略した場合は `run`/`runall` と同じ自動判定）

C++/Python は各ファイルごとに自由に混在できる（例: main は C++、
gen/brute は Python、など）。

動作:

- `seed` を `--seed-start` から1つずつ増やしながら `--count` 回繰り返す
- 各回: `gen <seed>` → 入力 → `main` と `brute` それぞれに投入 → 出力比較
  （行末空白・末尾改行の差は無視。`ioall`/`pyall` と同じ比較ロジック）
- 不一致 / `main` の異常終了(RE) / 制限時間超過(TLE、既定 2000ms。
  `--tl` か `tl.txt` で変更可)のいずれかが起きた時点で停止し、
  `stress_fail/` に `in.txt` / `main_out.txt` / `brute_out.txt` を保存する
- `brute` 自体が異常終了した場合は `brute` 側の不具合として個別に報告する
- `--debug` を付けると `main` だけ sanitizer 付き debug build でテストする
  （`gen`/`brute` は常に release build）
- 最後まで不一致が無ければ成功

---

## 使い方

```bash
stress                      # main_source は自動判定、100回
stress a                    # main_source を明示指定
stress --count 300          # 300回試す
stress --seed-start 1000    # シードを 1000 から始める
stress --debug              # main を sanitizer 付きでテスト
stress --tl 2000            # main の実行時間制限を 2000ms にする
```

生成される構成（`sumprob/` に `sumprob.cpp` / `gen.cpp` / `brute.cpp` がある場合）：
```text
sumprob/
├── sumprob.cpp
├── gen.cpp
├── brute.cpp
└── stress_fail/       # 不一致が見つかった場合のみ生成
    ├── in.txt
    ├── main_out.txt
    ├── main_err.txt    # main が RE した場合のみ
    └── brute_out.txt
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
