#!/bin/bash

# fetchsample/fetchcontest で共有する、Windows Downloads フォルダの解決ロジック。

resolve_downloads_dir() {
    local dir="/mnt/c/Users/$USER/Downloads"
    if [ -d "$dir" ]; then
        echo "$dir"
        return 0
    fi

    if command -v cmd.exe >/dev/null 2>&1 && command -v wslpath >/dev/null 2>&1; then
        local win_profile wsl_profile
        win_profile="$(cmd.exe /c "echo %USERPROFILE%" 2>/dev/null | tr -d '\r\n')"
        if [ -n "$win_profile" ]; then
            wsl_profile="$(wslpath -u "$win_profile" 2>/dev/null)" || wsl_profile=""
            if [ -n "$wsl_profile" ]; then
                dir="$wsl_profile/Downloads"
                if [ -d "$dir" ]; then
                    echo "$dir"
                    return 0
                fi
            fi
        fi
    fi

    return 1
}
