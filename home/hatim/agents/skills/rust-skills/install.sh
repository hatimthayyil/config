#!/usr/bin/env bash
set -euo pipefail

SKILL_DIR="$HOME/.claude/skills/rust-skills"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$SKILL_DIR/rules"

cp "$SCRIPT_DIR/CLAUDE.md" "$SKILL_DIR/"
cp "$SCRIPT_DIR/SKILL.md" "$SKILL_DIR/"
cp "$SCRIPT_DIR/rules/"*.md "$SKILL_DIR/rules/"

echo "Installed rust-skills to $SKILL_DIR"
