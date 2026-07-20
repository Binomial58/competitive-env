# サンプル取得パイプライン仕様（`fetchsample` / `unzips`）

問題ページの入出力サンプルをブラウザから取得し、WSL側の問題フォルダに自動展開する仕組みの仕様書です。
`sh/fetchsample` と `sh/unzips` の**現在の実装内容**をまとめています。

---

## 1. 全体の流れ

```
[Windows: ブラウザ拡張]                [WSL: fetchsample]              [WSL: unzips]
atcoder-sample-downloader          ①zipを探して問題フォルダへmv     ②zipを展開してsamples/へ
問題ページで「Sample DL」          （名前が一致しなければ           ③重複サンプルを削除
  ↓                                  最新zipを候補として確認）        ④sample-0をin.txt/out.txtへコピー
<問題名>.zip が                                                       ⑤zipを削除（デフォルト）
Windows側 Downloads に保存
```

- ブラウザ(Chrome/Edge)はWindows側で動くため、拡張機能が保存するzipもWindows側の `Downloads` フォルダに置かれる
- `fetchsample` はそのzipをWSL側から `/mnt/c/...` 経由で見つけ出し、カレントディレクトリ（問題フォルダ）に取り込む
- 実際の展開・整形処理は `unzips` に委譲される（`fetchsample` は最後に `exec unzips "./$NAME.zip"` を呼ぶだけ）

前提として、問題フォルダ名とzipファイル名（`<問題名>.zip`）が一致している必要があります（`mkprob` で作ったフォルダ名がそのまま該当します）。

---

## 2. `fetchsample`

### 2-1. 使い方

```bash
fetchsample [problem_name]
```

- 引数省略時: カレントディレクトリ名（`basename "$PWD"`）を問題名として使う
- `--help` / `-h`: 使い方を表示して終了

### 2-2. Windows Downloadsフォルダの解決（`resolve_downloads_dir`）

1. `/mnt/c/Users/$USER/Downloads` が存在すればそれを使う
   - `$USER` はWSL側のユーザー名。Windows側のユーザー名と一致していれば、これだけで解決する
2. 存在しない場合、`cmd.exe /c "echo %USERNAME%"` を呼んでWindows側のユーザー名を取得し、
   `/mnt/c/Users/<Windowsユーザー名>/Downloads` を試す
   （WSLのユーザー名とWindowsのユーザー名が異なる環境向けのフォールバック）
3. どちらも見つからなければ `error: could not locate Windows Downloads folder.` を出して終了

### 2-3. zipファイルの特定と取り込み

1. `<Downloads>/<problem_name>.zip` が存在する場合
   - そのままカレントディレクトリへ `mv`（`[MV] <元パス> -> ./<問題名>.zip`）
2. 完全一致するzipが無い場合
   - Downloads内の `*.zip` を列挙
   - 1件も無ければ `error: ... not found ..., and no other zip files there either.` で終了
   - 1件以上あれば、**更新日時が最も新しいzip**を「候補」として提示
     ```
     warning: <name>.zip not found.
     closest guess: <最新のzip名> (most recently downloaded zip in <Downloads>)
     use this file instead? [y/N]
     ```
   - `y`/`Y`/`yes`/`YES` 以外の入力（Enterのみ含む）は中断（`aborted.`）
   - 承諾した場合、その候補を `./<problem_name>.zip` という名前で `mv`
     （元のファイル名がなんであれ、問題名にリネームされる点に注意）
3. 取り込んだ `./<problem_name>.zip` を引数に `unzips` を呼び出して終了（`exec` のためプロセスが置き換わる＝以降は`unzips`の仕様がそのまま適用される）

### 2-4. 注意点

- 常に「問題フォルダの中で」実行する想定（複数問題フォルダをまたいだ一括処理はできない。一括処理は次章の`unzips`単体呼び出しで対応）
- Downloads内に該当zipが複数該当する状況は考慮していない（完全一致は常に1件のみ想定）

---

## 3. `unzips`

### 3-1. 使い方

```bash
unzips [--keep] [zip_file ...]
```

- 引数なし: カレントディレクトリの `*.zip` `*.ZIP` を対象にする
  - カレントに1件も無ければ、1階層下（`*/*.zip` `*/*.ZIP`）まで探索する
    （コンテストルート、例: `~/atcoder/abc999/` で実行し、配下の各問題フォルダに落ちているzipをまとめて処理する用途）
  - それでも1件も見つからなければ `error: no zip files found.` で終了
- 引数あり: 指定したzipファイルのみを対象にする（存在しなければ `warning: skip (not found): <path>` で読み飛ばす）
- `--keep`: 展開後にzipファイルを**削除しない**（デフォルトは削除）
- `--rm`: 明示的に削除する（デフォルトと同じ挙動。`--keep`と併用した場合は最後に指定した方が勝つ）
- 前提コマンド: `unzip`（無ければ `error: unzip command not found.` で終了）

### 3-2. 展開先の決定

対象zipのパスにディレクトリ区切り(`/`)が含まれるかどうかで展開先が変わります。

| 対象zip | 展開先(`dest`) | サンプル0コピー先(`target_dir`) |
|---|---|---|
| `./foo.zip`（同一ディレクトリ内） | `./samples/` | `.` |
| `abc999_a/foo.zip`（1階層下） | `abc999_a/samples/` | `abc999_a` |

つまり `abc999/` で一括実行した場合、各問題フォルダの `samples/` にそれぞれ正しく振り分けられます。

展開は `unzip -o <zip> -d <dest>`（`-o`: 確認なしで上書き）。

### 3-3. サンプルファイルの重複排除（`dedup_samples_dir`）

同じ内容のサンプルが番号違いで重複しているケース（AtCoderのzip構成でまれに発生）を取り除きます。

1. `<dest>/*.in` を列挙
2. ファイル名が `...-<数字>.in` の形式（例: `sample-0.in`）でなければスキップ（番号が取れないファイルは対象外）
3. 対応する `.out`（無い場合もあり得る）とペアで、内容のハッシュを計算
   - `sha256sum` → 無ければ `shasum -a 256` → 無ければ `cksum` の優先順で使用
   - ハッシュ対象: `in`の内容 + 区切り + `out`の内容（`out`が無ければ`__NO_OUT__`という印を使う）
4. 同一ハッシュを持つペアが複数あれば、**番号が小さいものだけ残し、それ以外(番号が大きい重複)を削除**
   - 削除時は `[DEDUP] removed duplicate: <相対パス>` を表示
5. 番号が取れるファイルが1つも無ければ何もしない

### 3-4. `in.txt` / `out.txt` の上書き（`overwrite_io_from_sample0`）

1. `<dest>` 内で番号が `0` のサンプル（例: `sample-0.in`）を探す
   - 見つからなければ `warning: sample-0 not found in <dest>; skip in.txt/out.txt update.` で何もせず終了
2. 対応する `.out` が無ければ `warning: sample-0.out not found for <in>; skip in.txt/out.txt update.` で終了
3. 両方あれば `<target_dir>/in.txt` と `<target_dir>/out.txt` にコピー（上書き）
   - `[SET] <target_dir>/in.txt <target_dir>/out.txt <- <元のベース名>` を表示
   - これが `run`（引数無し実行）で使われる入出力になる

### 3-5. zipファイルの削除

- デフォルト（`--keep`未指定）: 展開成功後に対象zipを削除（`[RM] <zip>`）
- `--keep`指定時: 削除せず残す

### 3-6. 複数zip指定時の挙動

複数のzip（または glob で複数マッチ）が対象になった場合、**1つずつ順番に**上記3-2〜3-5の処理が行われます。途中で1つの展開に失敗しても（`unzip`がエラーを返した場合）、`set -euo pipefail` によりスクリプト全体がその時点で停止します。

---

## 4. 前提とする入力zipの中身の形式

`unzips` は、zip展開後に得られるファイル名が次の形式であることを前提にしています。

```
sample-0.in
sample-0.out
sample-1.in
sample-1.out
...
```

（`sample-` の部分は任意の文字列でよく、末尾が `-<数字>.in` / `-<数字>.out` になっていれば認識される。これはブラウザ拡張 [atcoder-sample-downloader](https://github.com/Binomial58/personal-browser-tools/tree/main/extensions/atcoder-sample-downloader) が生成するzipの構成に合わせたもの）

---

## 5. 依存環境

- `bash`（`set -euo pipefail` 前提のスクリプト）
- `unzip` コマンド
- WSL上で `/mnt/c/...` によるWindowsファイルシステムへのアクセスが有効なこと
- （Downloadsパス解決のフォールバックで）`cmd.exe` がWSLから呼び出せること
- （重複排除で）`sha256sum` / `shasum` / `cksum` のいずれか（Ubuntuなら`sha256sum`が標準で入っている）

---

## 6. エラー・警告メッセージ一覧

| メッセージ | 発生元 | 意味・対処 |
|---|---|---|
| `could not locate Windows Downloads folder.` | fetchsample | `/mnt/c/Users/<user>/Downloads` が見つからない。WSLのマウント設定を確認 |
| `<name>.zip not found in ..., and no other zip files there either.` | fetchsample | Downloadsが空。ブラウザ拡張でのDLができているか確認 |
| `<name>.zip not found.` + `closest guess: ...` | fetchsample | 名前不一致。y/Nで確認後、最新zipを問題名にリネームして使う |
| `aborted.` | fetchsample | 上記確認で`y`以外を入力した場合 |
| `unzip command not found.` | unzips | `sudo apt install unzip` 等が必要 |
| `no zip files found.` | unzips | カレント/1階層下にzipが無い |
| `skip (not found): <path>` | unzips | 引数で明示したzipが存在しない |
| `sample-0 not found in ...; skip in.txt/out.txt update.` | unzips | zipの中に番号0のサンプルが無かった |
| `sample-0.out not found for ...; skip in.txt/out.txt update.` | unzips | 番号0の`.in`はあるが`.out`が無かった |

---

## 7. 使用例

問題フォルダ内で単体実行（通常のワークフロー）:

```bash
cd ~/atcoder/abc999/abc999_a
fetchsample                 # Downloadsの abc999_a.zip を取り込み、展開まで自動実行
```

zipを既に問題フォルダに手動で置いてある場合:

```bash
unzips                      # カレントの *.zip を展開
unzips --keep                # 展開後もzipを残す
unzips ./abc999_a.zip         # 特定のzipだけ指定
```

コンテストルートで一括展開（各問題フォルダに事前にzipを置いてある場合）:

```bash
cd ~/atcoder/abc999
unzips                      # abc999_*/*.zip をまとめて展開し、各問題フォルダのsamples/に振り分け
```
