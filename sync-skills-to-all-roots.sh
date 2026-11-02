#!/bin/bash
# 将技能仓库同步到本机各技能根目录。
# 用法：
#   ./sync-skills-to-all-roots.sh --check   # 只核对哈希与软链
#   ./sync-skills-to-all-roots.sh           # 备份旧副本，同步并核对
#
# 架构（2026-11-02 起）：
#   唯一编辑源 = 本仓库
#   软链根：~/.codex/skills、~/.dsh/skills、~/.workbuddy/skills、~/.trae-cn/skills
#   实体副本根：Kimi 托管目录、DeepSeek Harness 工作区、桌面 skills
#     —— Kimi 由 daimon 实体化，软链会被还原成目录，只能复制
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
SRC="$REPO_ROOT"
SKILLS=(change-list-authoring prd-rule-authoring requirements-docs-viewer)
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$HOME/Documents/skill-backups/$STAMP"

# 软链根：这些工具能跟随符号链接
LINK_ROOTS=(
  "$HOME/.codex/skills:Codex"
  "$HOME/.dsh/skills:DSH"
  "$HOME/.workbuddy/skills:WorkBuddy"
  "$HOME/.trae-cn/skills:Trae"
)

# 实体副本根：这些目录必须放真实文件
COPY_ROOTS=(
  "$HOME/Documents/deepseek-harness/default-workspace/skills"
  "$HOME/Desktop/代码文件仓库/skills"
)
KIMI_ROOT="$HOME/Library/Application Support/kimi-desktop/daimon-share/daimon/skills"

hash_dir() {
  (cd "$1" && find . -type f -exec shasum {} + 2>/dev/null | sed 's#  \./#  #' | sort | shasum | awk '{print $1}')
}

check_one() {
  local skill="$1" target="$2" label="$3"
  if [ ! -e "$target" ]; then
    echo "缺失: $label/$skill"
    return
  fi
  local h_src h_dst
  h_src="$(hash_dir "$SRC/$skill")"
  h_dst="$(hash_dir "$target")"
  if [ "$h_src" = "$h_dst" ]; then
    echo "一致: $label/$skill"
  else
    echo "不同: $label/$skill ($h_dst)"
  fi
}

check_link() {
  local skill="$1" root="$2" label="$3"
  if [ -L "$root/$skill" ]; then
    local real; real="$(readlink "$root/$skill")"
    [ "$real" = "$SRC/$skill" ] && echo "软链正确: $label/$skill" || echo "软链目标不符: $label/$skill -> $real"
  elif [ -e "$root/$skill" ]; then
    echo "非软链（实体副本）: $label/$skill"
  else
    echo "缺失: $label/$skill"
  fi
}

if [ "${1:-}" = "--check" ]; then
  echo "源: $SRC"
  for s in "${SKILLS[@]}"; do
    echo "--- $s"
    for pair in "${LINK_ROOTS[@]}"; do
      check_link "$s" "${pair%%:*}" "${pair##*:}"
    done
    for r in "${COPY_ROOTS[@]}" "$KIMI_ROOT"; do
      [ -e "$r/$s" ] && check_one "$s" "$r/$s" "$r"
    done
  done
  exit 0
fi

for s in "${SKILLS[@]}"; do
  [ -d "$SRC/$s" ] || { echo "源技能缺失: $SRC/$s"; exit 1; }
done
mkdir -p "$BACKUP"
echo "备份目录: $BACKUP"

for s in "${SKILLS[@]}"; do
  # 软链根：旧实体目录先备份再替换为软链
  for pair in "${LINK_ROOTS[@]}"; do
    root="${pair%%:*}"; label="${pair##*:}"
    mkdir -p "$root"
    if [ -L "$root/$s" ]; then
      rm -f "$root/$s"
    elif [ -e "$root/$s" ]; then
      cp -a "$root/$s" "$BACKUP/$label-$s"
      echo "backup: $label/$s"
      rm -rf "$root/$s"
    fi
    ln -s "$SRC/$s" "$root/$s"
    echo "symlink: $label/$s -> $SRC/$s"
  done

  # 实体副本根：整目录替换
  for r in "${COPY_ROOTS[@]}" "$KIMI_ROOT"; do
    mkdir -p "$r"
    if [ -e "$r/$s" ]; then
      cp -a "$r/$s" "$BACKUP/$(echo "$r" | sed "s|$HOME/||; s|/|_|g")-$s"
      rm -rf "$r/$s"
    fi
    # 用 -L 解引用，确保目标是实体文件而不是软链
    cp -aL "$SRC/$s" "$r/$s"
    echo "copied: $r/$s"
  done
done

echo
echo "=== 校验 ==="
for s in "${SKILLS[@]}"; do
  for pair in "${LINK_ROOTS[@]}"; do
    check_link "$s" "${pair%%:*}" "${pair##*:}"
  done
  for r in "${COPY_ROOTS[@]}" "$KIMI_ROOT"; do
    [ -e "$r/$s" ] && check_one "$s" "$r/$s" "$r"
  done
done
echo
echo "提示：各工具/会话需重启或重新加载技能目录后生效。"
