#!/usr/bin/env bash

# Solana Auditor Skill Installer
# Compatible with Solana AI Kit standards

set -e

echo "🔒 Installing solana-auditor-skill..."

TARGET_DIR="${1:-./.agents}"
SKILL_DIR="$TARGET_DIR/skills/solana-auditor-skill"
RULES_DIR="$TARGET_DIR/rules"
COMMANDS_DIR="$TARGET_DIR/commands"
AGENTS_DIR="$TARGET_DIR/agents"

mkdir -p "$SKILL_DIR/vulnerabilities"
mkdir -p "$SKILL_DIR/references"
mkdir -p "$RULES_DIR"
mkdir -p "$COMMANDS_DIR"
mkdir -p "$AGENTS_DIR"

# Copy skill logic (entry point + vulnerability modules + references)
cp skill/SKILL.md "$SKILL_DIR/"
cp skill/vulnerabilities/*.md "$SKILL_DIR/vulnerabilities/"
cp skill/references/*.md "$SKILL_DIR/references/"

# Copy agent persona
cp agents/auditor.md "$AGENTS_DIR/"

# Copy rules
cp rules/auditor.md "$RULES_DIR/"

# Copy commands
cp commands/*.json "$COMMANDS_DIR/"

echo "✅ solana-auditor-skill successfully installed into $TARGET_DIR"
echo ""
echo "Available commands:"
echo "  /audit      — Full formal security audit"
echo "  /quickscan  — Fast top-5 vulnerability check"
