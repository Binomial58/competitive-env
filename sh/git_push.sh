#!/bin/bash

# accept/save で共有する git push ロジック。
# 現在のブランチに upstream が無ければ、初回設定込みで
# git push --set-upstream origin <branch> を行う(force は使わない)。

push_current_branch() {
    if git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
        git push
    else
        local current_branch
        current_branch="$(git rev-parse --abbrev-ref HEAD)"
        git push --set-upstream origin "$current_branch"
    fi
}
