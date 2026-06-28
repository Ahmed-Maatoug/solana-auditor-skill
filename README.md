# Solana Auditor Skill

The `solana-auditor-skill` is a production-ready extension for the **Solana AI Kit** that transforms any generic coding agent into an elite Smart Contract Security Auditor. 

## The Problem it Solves
Currently, AI coding agents act as helpful pairs of hands—they write code, fix syntax, and explain logic. However, when dealing with Solana and the Anchor framework, **"working code" is not enough**. Submitting working but insecure code leads to massive exploits (e.g., missing PDA validation, account substitution, signer bypasses). 

The `solana-auditor-skill` solves the "Security Blindspot" problem. It forces the AI into a strict "Zero Trust" persona, equipping it with an encyclopedic knowledge of Solana-specific attack vectors, and mandates the generation of a formal security report rather than casual coding advice.

## What it Does
- **Progressive Vulnerability Loading:** Instead of dumping an entire security manual into the AI's context window (which wastes tokens and causes hallucination), this skill uses a routing architecture (`SKILL.md`). The AI dynamically loads specific markdown files (e.g., `pda_validation.md`, `cpi_security.md`) *only* if the audited codebase actually uses those features.
- **Formal Verification Reporting:** Forces the AI to generate a standardized Audit Report, including a Severity Matrix, Exploit Impact, and exact Code Remediation steps.
- **`/audit` Workflow Command:** Provides a custom command config so developers can simply type `/audit` to trigger a sweep.

## How to Install

This skill is designed to slot perfectly into standard AI workspace configurations.

### Automated Install (Recommended)
Run the provided installer script to copy the skill into your local `.agents` configuration folder.
```bash
chmod +x install.sh
./install.sh ./.agents
```

### Manual Install
1. Copy the `skill/` directory into your agent's skills configuration folder.
2. Copy `rules/auditor.md` into your agent's rules directory to enforce the Auditor Persona.
3. Copy `commands/audit.json` into your agent's slash commands directory.

## License
MIT License. See `LICENSE` for details.
