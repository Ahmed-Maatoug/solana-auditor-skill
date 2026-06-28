# Solana Auditor Skill

> **An all-in-one AI security expert for Solana/Anchor smart contracts.**

A production-ready skill for the [Solana AI Kit](https://github.com/solanabr/solana-ai-kit) that transforms any coding agent into an elite Smart Contract Security Auditor — not just a quick code reviewer, but a formal verification engine that produces structured audit reports with real-world exploit pattern matching.

## The Problem

AI coding agents are great at writing Solana programs, but they have a critical blind spot: **they don't think like attackers.** A generic agent will happily generate code that compiles and passes basic tests but is vulnerable to PDA seed manipulation, missing signer checks, integer overflow exploits, Token-2022 transfer hook abuse, or CPI privilege escalation.

The `solana-auditor-skill` solves this by forcing the AI into a strict adversarial security persona, equipping it with deep knowledge of Solana-specific attack vectors and real-world exploit case studies (Wormhole, Cashio, Crema, Mango Markets), and mandating formal audit report generation.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                   solana-auditor-skill                          │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  SKILL.md (Entry Point & Router)                          │  │
│  │  ├── Classifies audit scope (full / instruction / check)  │  │
│  │  ├── Routes to vulnerability sub-skills on demand         │  │
│  │  └── Defines audit report template & operating procedure  │  │
│  └───────────────────────────────────────────────────────────┘  │
│                              │                                  │
│                    progressive loading                          │
│                              ▼                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Vulnerability Knowledge Base (7 modules)                 │  │
│  │  ├── pda_validation.md        (Seeds, bumps, init)        │  │
│  │  ├── signer_authorization.md  (Missing signers, privesc)  │  │
│  │  ├── account_substitution.md  (Fake sysvars, mints)       │  │
│  │  ├── cpi_security.md          (Arbitrary CPI, re-entry)   │  │
│  │  ├── arithmetic_overflow.md   (Overflow, precision loss)  │  │
│  │  ├── closing_accounts.md      (Revival attacks)           │  │
│  │  └── token_extensions.md      (Token-2022 attack surface) │  │
│  └───────────────────────────────────────────────────────────┘  │
│                              │                                  │
│                    cross-references                              │
│                              ▼                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  References                                               │  │
│  │  └── real_world_exploits.md  (Wormhole, Cashio, Crema,    │  │
│  │                               Mango, Slope — $500M+ lost) │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐     │
│  │  agents/      │  │  rules/       │  │  commands/        │     │
│  │  auditor.md   │  │  auditor.md   │  │  audit.json       │     │
│  │  (Agent       │  │  (Zero Trust  │  │  quickscan.json   │     │
│  │   persona)    │  │   rules)      │  │  (2 commands)     │     │
│  └──────────────┘  └──────────────┘  └──────────────────┘     │
└─────────────────────────────────────────────────────────────────┘
```

## What's Included

| Component | Description |
|---|---|
| [`skill/SKILL.md`](skill/SKILL.md) | Entry point with routing table, operating procedure, and report template |
| [`skill/vulnerabilities/`](skill/vulnerabilities/) | 7 deep-dive vulnerability modules with vulnerable + secure Rust/Anchor code |
| [`skill/references/`](skill/references/) | Real-world exploit case studies for pattern matching during audits |
| [`agents/auditor.md`](agents/auditor.md) | Dedicated auditor agent persona with workflow and behavior specification |
| [`rules/auditor.md`](rules/auditor.md) | Agent rules enforcing Zero Trust adversarial mindset |
| [`commands/audit.json`](commands/audit.json) | `/audit` — full formal security audit |
| [`commands/quickscan.json`](commands/quickscan.json) | `/quickscan` — fast top-5 vulnerability check |
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
| **Token-2022** | `token_extensions.md` | Transfer hooks, permanent delegates, transfer fees, confidential transfers |

## What Makes This Unique

1. **Token-2022 coverage** — The only auditor skill that covers Solana's next-gen token standard attack surfaces (transfer hooks, permanent delegates, confidential transfers). Current to the 2026 stack.
2. **Real-world exploit pattern matching** — Cross-references findings against 5 documented Solana exploits totaling $500M+ in losses (Wormhole, Cashio, Crema, Mango, Slope).
3. **Dual commands** — `/audit` for comprehensive formal reports, `/quickscan` for fast CI/CD-style checks.
4. **Progressive loading** — 7 vulnerability modules loaded on-demand, never bloating the context window.
5. **Agent + Rules + Commands** — Full trifecta of agent persona, behavioral rules, and workflow commands.

## Installation

### Automated (Recommended)
```bash
chmod +x install.sh
./install.sh ./.agents
```

### Manual
1. Copy `skill/` → your agent's `skills/solana-auditor-skill/` directory
2. Copy `agents/auditor.md` → your agent's `agents/` directory
3. Copy `rules/auditor.md` → your agent's `rules/` directory
4. Copy `commands/*.json` → your agent's `commands/` directory

### As a Git Submodule
```bash
git submodule add https://github.com/Ahmed-Maatoug/solana-auditor-skill.git .agents/skills/solana-auditor-skill
```

## Usage

Once installed, the skill activates automatically when the agent encounters Solana/Anchor code. You can also explicitly trigger:

- **`/audit`** — Full formal security audit with severity matrix and remediation code
- **`/quickscan`** — Fast pass checking the top 5 most critical patterns
- *"Audit this Anchor program"* — Natural language trigger
- *"Is this instruction safe?"* — Targeted single-instruction review

## License

[MIT](LICENSE)
