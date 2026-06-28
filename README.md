# Solana Auditor Skill

> **An all-in-one AI security expert for Solana/Anchor smart contracts.**

A production-ready skill for the [Solana AI Kit](https://github.com/solanabr/solana-ai-kit) that transforms any coding agent into an elite Smart Contract Security Auditor — not just a quick code reviewer, but a formal verification engine that produces structured audit reports.

## The Problem

AI coding agents are great at writing Solana programs, but they have a critical blind spot: **they don't think like attackers.** A generic agent will happily generate code that compiles and passes basic tests but is vulnerable to PDA seed manipulation, missing signer checks, integer overflow exploits, or CPI privilege escalation.

The `solana-auditor-skill` solves this by forcing the AI into a strict adversarial security persona, equipping it with deep knowledge of Solana-specific attack vectors, and mandating formal audit report generation.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                   solana-auditor-skill                          │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  SKILL.md (Entry Point & Router)                          │  │
│  │  ├── Classifies audit scope (full / instruction / check)  │  │
│  │  ├── Routes to vulnerability sub-skills on demand         │  │
│  │  └── Defines audit report template                        │  │
│  └───────────────────────────────────────────────────────────┘  │
│                              │                                  │
│                    progressive loading                          │
│                              ▼                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Vulnerability Knowledge Base                             │  │
│  │  ├── pda_validation.md        (Seeds, bumps, init)        │  │
│  │  ├── signer_authorization.md  (Missing signers, privesc)  │  │
│  │  ├── account_substitution.md  (Fake sysvars, mints)       │  │
│  │  ├── cpi_security.md          (Arbitrary CPI, re-entry)   │  │
│  │  ├── arithmetic_overflow.md   (Overflow, precision loss)  │  │
│  │  └── closing_accounts.md      (Revival attacks)           │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────┐  ┌──────────────────┐                        │
│  │  rules/       │  │  commands/        │                        │
│  │  auditor.md   │  │  audit.json       │                        │
│  │  (Zero Trust  │  │  (/audit trigger) │                        │
│  │   persona)    │  │                   │                        │
│  └──────────────┘  └──────────────────┘                        │
└─────────────────────────────────────────────────────────────────┘
```

## What's Included

| Component | Description |
|---|---|
| [`skill/SKILL.md`](skill/SKILL.md) | Entry point with routing table, operating procedure, and report template |
| [`skill/vulnerabilities/`](skill/vulnerabilities/) | 6 deep-dive vulnerability files with vulnerable + secure Rust/Anchor code examples |
| [`rules/auditor.md`](rules/auditor.md) | Agent persona rules enforcing Zero Trust adversarial mindset |
| [`commands/audit.json`](commands/audit.json) | `/audit` slash command to trigger a full security sweep |
| [`install.sh`](install.sh) | One-line installer for `.agents/` workspace configuration |

## Vulnerability Coverage

| Attack Surface | Sub-Skill | Key Checks |
|---|---|---|
| PDA Manipulation | `pda_validation.md` | Missing seeds, non-canonical bumps, re-initialization |
| Privilege Escalation | `signer_authorization.md` | Missing `Signer` constraint, owner/authority confusion |
| Account Spoofing | `account_substitution.md` | Fake sysvars, fake token programs, mint substitution |
| CPI Exploits | `cpi_security.md` | Arbitrary CPI targets, missing signer seeds, indirect re-entrancy |
| Math Exploits | `arithmetic_overflow.md` | Unchecked arithmetic, precision loss, unsafe `as` casts |
| Account Lifecycle | `closing_accounts.md` | Revival attacks, missing discriminator reset |

## Installation

### Automated (Recommended)
```bash
chmod +x install.sh
./install.sh ./.agents
```

### Manual
1. Copy `skill/` → your agent's `skills/solana-auditor-skill/` directory
2. Copy `rules/auditor.md` → your agent's `rules/` directory
3. Copy `commands/audit.json` → your agent's `commands/` directory

### As a Git Submodule
```bash
git submodule add https://github.com/Ahmed-Maatoug/solana-auditor-skill.git .agents/skills/solana-auditor-skill
```

## Usage

Once installed, simply ask your agent:
- *"Audit this Anchor program for security vulnerabilities"*
- *"Check this instruction for missing signer verification"*
- *"Generate a formal audit report for this codebase"*

Or use the `/audit` slash command to trigger a comprehensive security sweep.

## License

[MIT](LICENSE)
