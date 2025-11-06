#!/usr/bin/env bash
set -euo pipefail

# 项目根目录（从配置或环境读取），默认 $HOME/work/yishulun_blog_mdandcode
PROJECT_ROOT="${SETALIAS_PROJECT_ROOT:-}"
# Prefer hidden rc; fallback to legacy config path
if [ -z "$PROJECT_ROOT" ] && [ -f "$HOME/.setaliasrc" ]; then
  # shellcheck source=/dev/null
  source "$HOME/.setaliasrc"
elif [ -z "$PROJECT_ROOT" ] && [ -f "$HOME/.setalias/config" ]; then
  # shellcheck source=/dev/null
  source "$HOME/.setalias/config"
fi
PROJECT_ROOT="${SETALIAS_PROJECT_ROOT:-$HOME/work/yishulun_blog_mdandcode}"

# 目标目录
TARGET_DIR="$PROJECT_ROOT"

# 检查目标目录是否存在
if [ ! -d "$TARGET_DIR" ]; then
  printf "\n错误：目标目录 %s 不存在！\n\n" "$TARGET_DIR"
  exit 1
fi

# 导航到目标目录
cd "$TARGET_DIR" || { printf "\n错误：无法进入目录 %s！\n\n" "$TARGET_DIR"; exit 1; }

# 执行 push.sh 脚本
"$HOME/.push.sh" "自动提交：$(date +'%Y-%m-%d %H:%M:%S')"
