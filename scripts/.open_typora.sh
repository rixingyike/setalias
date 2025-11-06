#!/usr/bin/env bash
set -euo pipefail

# 跨平台打开 Typora
# 支持：macOS、Linux、Windows (Git Bash/MSYS2/Cygwin)、WSL

open_typora() {
  local file="${1:-}"

  # WSL 检测（Linux 内核但运行在 Windows）
  local is_wsl=0
  if [[ "${OSTYPE:-}" == linux* ]]; then
    if grep -qi microsoft /proc/version 2>/dev/null; then
      is_wsl=1
    fi
  fi

  case "${OSTYPE:-}" in
    darwin*)
      # macOS：通过 open -a 调用应用
      if [[ -z "$file" ]]; then
        open -a "Typora"
      else
        open -a "Typora" "$file"
      fi
      ;;

    linux*)
      if [[ "$is_wsl" -eq 1 ]]; then
        # WSL：借助 cmd.exe 的 start，并用 wslpath 转换 Windows 路径
        local typora_path_win
        typora_path_win=$(wslpath -w "$HOME/AppData/Local/Programs/Typora/Typora.exe")
        if [[ -z "$file" ]]; then
          cmd.exe /c start "" "$typora_path_win"
        else
          local file_win
          file_win=$(wslpath -w "$file")
          cmd.exe /c start "" "$typora_path_win" "$file_win"
        fi
      else
        # 纯 Linux：优先 typora，其次 xdg-open（若未安装 Typora）
        if command -v typora >/dev/null 2>&1; then
          if [[ -z "$file" ]]; then
            nohup typora >/dev/null 2>&1 &
          else
            nohup typora "$file" >/dev/null 2>&1 &
          fi
        elif command -v xdg-open >/dev/null 2>&1; then
          if [[ -z "$file" ]]; then
            echo "未找到 typora，使用 xdg-open 需要传入文件" >&2
            exit 1
          else
            xdg-open "$file" >/dev/null 2>&1 || true
          fi
        else
          echo "未找到 typora 或 xdg-open，请安装后重试" >&2
          exit 1
        fi
      fi
      ;;

    msys*|cygwin*)
      # Windows (Git Bash/MSYS2/Cygwin)：用 cmd.exe 的 start 打开 .exe
      local typora_path="$HOME/AppData/Local/Programs/Typora/Typora.exe"
      # 转换为 Windows 路径（如 C:\Users\...）
      if command -v cygpath >/dev/null 2>&1; then
        typora_path=$(cygpath -w "$typora_path")
        if [[ -n "$file" ]]; then
          file=$(cygpath -w "$file")
        fi
      fi
      if [[ -z "$file" ]]; then
        cmd.exe /c start "" "$typora_path"
      else
        cmd.exe /c start "" "$typora_path" "$file"
      fi
      ;;

    *)
      echo "不支持的操作系统: ${OSTYPE:-unknown}" >&2
      exit 1
      ;;
  esac
}

open_typora "$@"
