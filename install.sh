#!/usr/bin/env bash

# Solana Auditor Skill Installer
# Compatible with Solana AI Kit standards

set -e

echo "Installing solana-auditor-skill..."

TARGET_DIR="${1:-./.agents}"
SKILL_DIR="$TARGET_DIR/skills/solana-auditor-skill"
RULES_DIR="$TARGET_DIR/rules"
COMMANDS_DIR="$TARGET_DIR/commands"

mkdir -p "$SKILL_DIR"
mkdir -p "$RULES_DIR"
mkdir -p "$COMMANDS_DIR"

# Copy skill logic
cp -r skill/* "$SKILL_DIR/"

# Copy rules
cp rules/auditor.md "$RULES_DIR/"

# Copy commands
cp commands/audit.json "$COMMANDS_DIR/"

echo "✅ solana-auditor-skill successfully installed into $TARGET_DIR"
echo "You can now use the /audit command in your AI workspace."
