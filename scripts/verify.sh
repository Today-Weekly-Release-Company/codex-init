#!/usr/bin/env sh

set -u

CODEX_CONFIG_DIR="${CODEX_HOME:-$HOME/.codex}"
AGENTS_FILE="$CODEX_CONFIG_DIR/AGENTS.md"
FAILED=0

pass() {
  printf 'PASS  %s\n' "$1"
}

fail() {
  printf 'FAIL  %s\n' "$1"
  FAILED=1
}

if command -v rtk >/dev/null 2>&1 && rtk gain >/dev/null 2>&1; then
  pass "RTK $(rtk --version 2>/dev/null)"
else
  fail "RTK 不可用或存在同名工具冲突"
fi

if [ -f "$AGENTS_FILE" ] \
  && grep -Fq '<!-- AI_DEV_KIT_START -->' "$AGENTS_FILE" \
  && grep -Fq '<!-- AI_DEV_KIT_END -->' "$AGENTS_FILE"; then
  pass "全局 AGENTS.md 已同步"
else
  fail "全局 AGENTS.md 缺少 codex-init 托管区块"
fi

if [ -s "$CODEX_CONFIG_DIR/AGENTS.override.md" ]; then
  fail "AGENTS.override.md 优先于全局 AGENTS.md，需确认规则生效方式"
else
  pass "全局 AGENTS.md 未被 override 文件遮蔽"
fi

exit "$FAILED"
