# Closing Account Vulnerability Check

When a Solana account is "closed" (its lamports are drained), the account data persists in memory for the remainder of the transaction. This creates a dangerous window for revival attacks.

## 1. Account Revival Attack
After closing an account by zeroing its lamports, an attacker can re-fund the account within the same transaction (or a subsequent instruction in the same transaction), effectively "reviving" it with stale or attacker-controlled data.

**Vulnerable Pattern:**
```rust
// DANGEROUS: Only drains lamports, does not zero data or set discriminator
pub fn close_account(ctx: Context<CloseAccount>) -> Result<()> {
    let dest = &ctx.accounts.destination;
    let account = &ctx.accounts.target_account;
    **dest.to_account_info().try_borrow_mut_lamports()? += account.to_account_info().lamports();
    **account.to_account_info().try_borrow_mut_lamports()? = 0;
    Ok(())
}
```

**Secure Pattern (Anchor):**
```rust
#[derive(Accounts)]
pub struct CloseAccount<'info> {
    #[account(mut, close = destination)]  // Anchor zeros data + transfers lamports
    pub target_account: Account<'info, MyState>,
    #[account(mut)]
    pub destination: SystemAccount<'info>,
}
```

## 2. Missing Discriminator Reset
When manually closing accounts (without Anchor's `close` constraint), the 8-byte account discriminator must be overwritten. If it is not, the account can be deserialized again after revival.

**Audit Checklist:**
- Verify that `close = destination` is used in Anchor, OR that manual close logic zeros ALL account data (not just lamports).
- Check that closed accounts are not referenced later in the same transaction.
- Flag any pattern where an account is closed in one instruction and potentially re-initialized in another instruction within the same transaction.
