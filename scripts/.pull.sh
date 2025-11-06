#!/usr/bin/env bash
set -euo pipefail

# 确认 git 可用
if ! command -v git >/dev/null 2>&1; then
  printf "错误：未找到 git。\n" >&2
  exit 1
fi

# 确认当前目录是仓库
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  printf "错误：当前目录不是 Git 仓库！\n" >&2
  exit 1
fi

# 安全拉取（仅快速前进）
git pull --ff-only
