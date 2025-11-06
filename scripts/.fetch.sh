#!/usr/bin/env bash
set -euo pipefail

# 确认 git 可用
if ! command -v git >/dev/null 2>&1; then
  printf "\n错误：未找到 git，请安装后重试。\n" >&2
  exit 1
fi

# 获取当前分支名称（兼容旧版 git）
BRANCH=$(git branch --show-current 2>/dev/null || git rev-parse --abbrev-ref HEAD 2>/dev/null || true)

# 检查是否在 Git 仓库中
if [ -z "${BRANCH:-}" ]; then
  printf "\n错误：当前目录不是 Git 仓库！\n"
  exit 1
fi

# 提示用户确认操作
printf "\n警告：这将强制从远程仓库覆盖本地修改，所有未提交的更改将被丢弃！\n"
read -p "是否继续？(y/n): " CONFIRM

if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
  printf "\n操作已取消。\n"
  exit 0
fi

# 强制从远程仓库拉取最新代码
printf "\n正在强制从远程仓库拉取最新代码并覆盖本地修改...\n"
git fetch origin
git reset --hard "origin/$BRANCH"
git clean -fd

# 输出完成信息
printf "\n操作完成！本地分支 %s 已强制更新为远程仓库的最新状态。\n\n" "$BRANCH"
