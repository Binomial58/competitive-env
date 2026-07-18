# Shell Environment Summary (`~/.zshrc`)

このファイルは、現在の `~/.zshrc` の有効設定を要約したメモです。

## Base

- Shell framework: Oh My Zsh
- `ZSH="$HOME/.oh-my-zsh"`
- `ZSH_THEME="clean"`
- `plugins=(git)`
- `source $ZSH/oh-my-zsh.sh`

## PATH

- `export PATH="$HOME/Github/competitive-env/sh:$PATH"`
- これにより `competitive-env/sh` 配下のコマンドが直接実行可能
- ただし `resolve_target.sh` / `io_compare.sh` / `mkprob_core.sh` / `cpp_re_report.sh` は
  他スクリプトから `source` される内部専用ライブラリで、直接コマンドとして
  呼び出すものではない

## Custom Behaviors

### `command_not_found_handler`

- `py0` 〜 `py999` を `py <番号>` として実行
- `run0` 〜 `run999` を `run <番号>` として実行
- 上記以外は通常の `command not found` を表示

### `mkprob` function

- `mkprob <lang> <problem>` 実行後、生成した `<problem>` ディレクトリへ自動で `cd`
- 実体コマンドは `command mkprob "$@"` で呼び出し

### `mkcontest` function

- `mkcontest <lang> <contest_prefix> ...` 実行後、生成したコンテスト親フォルダ
  （`<contest_prefix>/`）へ自動で `cd`（`mkprob` と同じ仕組み）
- 実体コマンドは `command mkcontest "$@"` で呼び出し

## Notes

- `.zshrc` の大半は Oh My Zsh のデフォルトコメント
- 実運用上重要なのは `PATH`・`command_not_found_handler`・`mkprob`/`mkcontest` 関数
- このリポジトリの `.zshrc` は `~/.zshrc` の手動同期コピー（symlink ではない）。
  pnpm インストーラなど外部ツールが `~/.zshrc` に直接追記することがあるため、
  両者は完全には一致しない場合がある。競技プログラミング関連の関数を
  変更したときは、リポジトリ側だけでなく `~/.zshrc` 側にも反映が必要。
