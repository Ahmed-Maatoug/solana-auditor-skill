# Account Substitution Check

Account substitution is a critical vulnerability where an attacker passes a malicious account they control in place of a required system account, program, or data account.

## 1. Fake Sysvars
If a program uses sysvar data (Clock, Rent, StakeHistory) but accepts them as raw `AccountInfo` without verifying the pubkey, an attacker can fabricate sysvar data.

**Vulnerable Pattern:**
```rust
// DANGEROUS: Attacker can pass a fake Clock account with manipulated timestamp
#[derive(Accounts)]
pub struct ClaimRewards<'info> {
    /// CHECK: "Clock sysvar" — but no verification!
    pub clock: AccountInfo<'info>,
}

pub fn claim(ctx: Context<ClaimRewards>) -> Result<()> {
    let clock_data = Clock::from_account_info(&ctx.accounts.clock)?;
    // Attacker faked the timestamp to bypass the timelock!
    require!(clock_data.unix_timestamp > lockup_end, ErrorCode::TooEarly);
    // ...
}
```

**Secure Pattern (Anchor):**
```rust
#[derive(Accounts)]
pub struct ClaimRewards<'info> {
    pub clock: Sysvar<'info, Clock>,  // Anchor auto-verifies the pubkey
}
```

## 2. Fake Token Program
When transferring tokens, an attacker might substitute a malicious program that mimics the SPL Token interface but steals funds instead.

**Vulnerable Pattern:**
```rust
// DANGEROUS: token_program is not verified
#[derive(Accounts)]
pub struct TransferTokens<'info> {
    /// CHECK: Not verified as SPL Token
    pub token_program: AccountInfo<'info>,
}
```

**Secure Pattern (Anchor):**
```rust
#[derive(Accounts)]
pub struct TransferTokens<'info> {
    pub token_program: Program<'info, Token>,  // Anchor verifies program_id
}
```

## 3. Fake Mint / Token Account Substitution
An attacker creates their own mint or token account and passes it instead of the protocol's expected one.

**Vulnerable Pattern:**
```rust
// DANGEROUS: No mint or authority verification
#[derive(Accounts)]
pub struct Deposit<'info> {
    #[account(mut)]
    pub vault: Account<'info, TokenAccount>,  // Could be attacker's account
    #[account(mut)]
    pub user_token: Account<'info, TokenAccount>,
}
```

**Secure Pattern:**
```rust
#[derive(Accounts)]
pub struct Deposit<'info> {
    #[account(
        mut,
        token::mint = expected_mint,
        token::authority = vault_authority,
    )]
    pub vault: Account<'info, TokenAccount>,
    #[account(
        mut,
        token::mint = expected_mint,
        token::authority = user,
    )]
    pub user_token: Account<'info, TokenAccount>,
    pub expected_mint: Account<'info, Mint>,
}
```

**Audit Checklist:**
- Every `AccountInfo` that represents a sysvar, program, mint, or token account must have type-level or constraint-level verification.
- Search for `/// CHECK:` comments — each one is a potential vulnerability. Verify the justification is sound.
- Ensure all `Program<'info, X>` types match the expected program (Token, System, AssociatedToken, etc.).
