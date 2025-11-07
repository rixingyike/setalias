#!/usr/bin/env bash
set -euo pipefail

# 获取当前年份
CURRENT_YEAR=$(date +"%Y")

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

# 目标目录（包含年份子目录）
TARGET_DIR="$PROJECT_ROOT/source/blog/$CURRENT_YEAR"

# 检查目标目录是否存在
if [ ! -d "$TARGET_DIR" ]; then
  printf "\n错误：目标目录 %s 不存在！\n" "$TARGET_DIR"
  exit 1
fi

# 获取当前最大数字文件名
MAX_NUM=$(ls "$TARGET_DIR" | grep -E '^[0-9]+\.md$' | sed 's/\.md//' | sort -n | tail -1)

# 如果没有找到数字文件，默认从 1 开始
if [ -z "${MAX_NUM:-}" ]; then
  MAX_NUM=0
fi

# 新文件名
NEW_NUM=$((MAX_NUM + 1))
NEW_FILE="$TARGET_DIR/$NEW_NUM.md"

# 获取当前时间
CREATE_TIME=$(date +"%Y/%m/%d %H:%M:%S")

# 获取标题
TITLE="${1:-标题}"

# 创建文件并写入默认内容
cat <<EOF > "$NEW_FILE"
---
createTime: $CREATE_TIME
tags: []
---

# $TITLE
EOF

# 输出成功信息
printf "\n文件已创建：%s\n\n" "$NEW_FILE"

# 使用同目录下的 .open.sh 脚本打开文件（处理跨平台）
"$HOME/.open.sh" "$NEW_FILE"
