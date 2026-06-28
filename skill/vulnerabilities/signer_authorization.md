# Signer Authorization Check

Missing or incorrect signer checks are one of the most exploited vulnerabilities in Solana programs. Without proper authorization, any user can call privileged instructions.

## 1. Missing `Signer` Constraint
If an instruction modifies state owned by a specific user (e.g., withdrawing tokens from their vault), the program must verify that the caller is actually that user.

**Vulnerable Pattern (Anchor):**
```rust
// DANGEROUS: `authority` is not verified as a signer
#[derive(Accounts)]
pub struct Withdraw<'info> {
    #[account(mut)]
    pub vault: Account<'info, TokenAccount>,
    /// CHECK: No signer check!
    pub authority: AccountInfo<'info>,
}
```

**Secure Pattern:**
```rust
#[derive(Accounts)]
pub struct Withdraw<'info> {
    #[account(mut, has_one = authority)]
    pub vault: Account<'info, TokenAccount>,
    pub authority: Signer<'info>,  // Enforces signature verification
}
```

## 2. Owner vs Authority Confusion
Solana accounts have an `owner` field (the program that owns the account data) and often a logical `authority` stored within the data. Confusing these leads to privilege escalation.

**Audit Checklist:**
- Ensure `has_one = authority` or equivalent checks are present on all state-modifying instructions.
- Verify that admin/governance instructions use a separate, hardcoded admin pubkey or a multi-sig PDA.
- Check for instructions that accept an `authority` but never verify it against the account's stored authority field.

## 3. Privilege Escalation via Unchecked Instruction Access
If a program has admin-only instructions (e.g., `update_config`, `pause_protocol`), verify that they cannot be called by arbitrary users.

**Audit Checklist:**
- Look for `#[access_control(...)]` attributes or manual `require!()` checks.
- Ensure upgrade authority is properly handled (or the program is marked as immutable via `solana program deploy --final`).
- Flag any instruction that modifies global config without requiring a specific signer.
