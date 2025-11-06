#!/usr/bin/env bash
set -euo pipefail

# 可选：先拉取最新代码
if [ -x "$HOME/.pull.sh" ]; then
  "$HOME/.pull.sh"
fi

# 确认 git 可用
if ! command -v git >/dev/null 2>&1; then
  printf "错误：未找到 git。\n" >&2
  exit 1
fi

# 获取当前分支名称（兼容旧版 git）
BRANCH=$(git branch --show-current 2>/dev/null || git rev-parse --abbrev-ref HEAD 2>/dev/null || true)

# 检查是否在 Git 仓库中
if [ -z "${BRANCH:-}" ]; then
  printf "错误：当前目录不是 Git 仓库！\n" >&2
  exit 1
fi

# 生成提交信息
if [ -z "${1:-}" ]; then
  COMMENT="自动提交: $(date +%Y-%m-%d_%H:%M:%S)"
else
  COMMENT="$1"
fi

# 执行 Git 操作
git add -A

# 若无暂存变更则跳过 commit
if git diff --cached --quiet; then
  printf "\n无暂存变更，跳过提交。\n"
else
  git commit -m "$COMMENT"
fi

git push origin "$BRANCH"

# 输出完成信息
printf "\n提交完成！分支: %s，提交信息: %s\n" "$BRANCH" "$COMMENT"
