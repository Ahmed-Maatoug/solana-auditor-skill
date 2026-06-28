# Solana Auditor Skill

The `solana-auditor-skill` is a production-ready extension for AI coding agents that transforms them into elite Smart Contract Security Auditors. 

It is designed to be **progressively-loaded** and **token-efficient**, meaning the AI will only load the specific vulnerability checks (like PDA validation or Account Substitution) that are relevant to the Rust/Anchor code being analyzed.

## Features
- **Progressive Knowledge Base:** Modular vulnerability checks that don't bloat the AI's context window.
- **Strict Persona:** Built-in rules to enforce a "Zero Trust" exploit mindset.
- **Formal Reporting:** Forces the AI to output findings in a standardized Audit Report format (Severity, Impact, Remediation).

## Installation

To install this skill into your AI coding agent environment, simply copy the `skill/` and `rules/` directories into your agent's customization root (e.g., `~/.gemini/config/` or your workspace's `.agents/` folder).

### Manual Installation
1. Clone this repository.
2. Copy `skill/SKILL.md` and the `skill/vulnerabilities/` folder to your agent's skills directory.
3. Copy `rules/auditor.md` to your agent's rules directory (or append it to `AGENTS.md`).

## Usage
Once installed, simply ask your agent to "audit this Solana program" or paste your Anchor code. The skill will automatically trigger, routing the AI through the vulnerability checks and generating a formal security report.
