# PDA Validation Check

Program Derived Addresses (PDAs) are the backbone of Solana program state. Improper validation is the #1 most common vulnerability in Anchor programs.

## 1. Missing Seed Validation
If an instruction accepts a PDA but does not verify the exact seeds used to derive it, an attacker can pass any account they control.

**Vulnerable Pattern:**
```rust
// DANGEROUS: No seed verification — attacker can pass any account
#[derive(Accounts)]
pub struct UpdatePool<'info> {
    /// CHECK: No constraints!
    #[account(mut)]
    pub pool: AccountInfo<'info>,
}
```

**Secure Pattern (Anchor):**
```rust
#[derive(Accounts)]
pub struct UpdatePool<'info> {
    #[account(
        mut,
        seeds = [b"pool", pool.token_mint.as_ref()],
        bump = pool.bump,
    )]
    pub pool: Account<'info, PoolState>,
}
```

**Audit Checklist:**
- Ensure every PDA account has `seeds = [...]` and `bump` constraints in the `Accounts` struct.
- If manual validation is used (native Solana), verify that `Pubkey::find_program_address` is called and compared against the provided account key.
- Check that seeds include all relevant discriminating data (e.g., user pubkey, mint address) to prevent cross-user PDA collisions.

## 2. Canonical Bump Verification
`Pubkey::find_program_address` returns the highest valid bump (the "canonical bump"). Using a non-canonical bump allows attackers to derive multiple valid PDAs with the same seeds.

**Vulnerable Pattern:**
```rust
// DANGEROUS: Bump is user-supplied, attacker can use non-canonical bump
pub fn init(ctx: Context<Init>, bump: u8) -> Result<()> {
    let (expected_key, _) = Pubkey::create_program_address(
        &[b"vault", &[bump]],  // User controls the bump!
        ctx.program_id,
    )?;
    // ...
}
```

**Secure Pattern:**
```rust
// Anchor handles canonical bumps automatically
#[derive(Accounts)]
pub struct Init<'info> {
    #[account(init, seeds = [b"vault"], bump, payer = user, space = 8 + 32)]
    pub vault: Account<'info, Vault>,
}
```

**Audit Checklist:**
- Verify that bumps are never accepted as instruction arguments.
- Ensure bumps are stored on-chain at initialization and reused in subsequent instructions (not recalculated).

## 3. Re-Initialization Guard
If a PDA can be initialized multiple times, an attacker can overwrite existing state.

**Vulnerable Pattern:**
```rust
// DANGEROUS: init_if_needed allows overwriting existing state
#[account(init_if_needed, seeds = [b"user", user.key().as_ref()], bump, payer = user, space = 100)]
pub user_account: Account<'info, UserState>,
```

**Audit Checklist:**
- Flag ALL uses of `init_if_needed` as a warning.
- If `init_if_needed` is intentional, verify that an `is_initialized` flag is checked within the instruction logic.
- Prefer `init` (which fails if the account already exists) over `init_if_needed`.
