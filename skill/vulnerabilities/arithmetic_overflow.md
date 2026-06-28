# Arithmetic & Logic Vulnerability Check

Integer overflows, underflows, and precision loss are responsible for some of the largest DeFi exploits in history. On Solana, Rust's default checked arithmetic in debug mode does NOT apply in release builds unless explicitly configured.

## 1. Integer Overflow/Underflow
By default, Rust release builds use **wrapping** arithmetic. A balance of `1` minus `2` will silently wrap to `u64::MAX` (18,446,744,073,709,551,615).

**Vulnerable Pattern:**
```rust
// DANGEROUS in release mode: will wrap instead of panic
pub fn withdraw(ctx: Context<Withdraw>, amount: u64) -> Result<()> {
    let vault = &mut ctx.accounts.vault;
    vault.balance = vault.balance - amount;  // No checked subtraction!
    Ok(())
}
```

**Secure Pattern:**
```rust
pub fn withdraw(ctx: Context<Withdraw>, amount: u64) -> Result<()> {
    let vault = &mut ctx.accounts.vault;
    vault.balance = vault.balance
        .checked_sub(amount)
        .ok_or(ErrorCode::InsufficientFunds)?;
    Ok(())
}
```

**Audit Checklist:**
- Search for all uses of `+`, `-`, `*`, `/` on integer types — each one should use `checked_add`, `checked_sub`, `checked_mul`, `checked_div`.
- Alternatively, verify that `Cargo.toml` has `overflow-checks = true` under `[profile.release]`.
- Check for casts between integer sizes (e.g., `u128 as u64`) which silently truncate.

## 2. Precision Loss in Token Math
When calculating fees, interest, or shares, division can silently lose precision, allowing attackers to extract rounding dust over many transactions.

**Audit Checklist:**
- Look for division before multiplication (always multiply first to preserve precision).
- Verify that fee calculations use basis points (e.g., `amount * fee_bps / 10_000`) rather than floating-point-like percentages.
- Check for rounding direction: protocols should round **against** the user in withdrawals and **in favor of** the protocol in deposits.

## 3. Unsafe Type Casting
Casting from a larger integer type to a smaller one (e.g., `u128 as u64`) silently truncates. This can be exploited when large values are involved.

**Audit Checklist:**
- Flag all `as` casts between numeric types.
- Recommend `try_into().unwrap()` or `try_from()` with proper error handling instead.
