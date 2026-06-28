# Cross-Program Invocation (CPI) Security Check

CPI allows Solana programs to call other programs. When auditing CPI usage, attackers can exploit trust boundaries between programs to steal funds or bypass access controls.

## 1. Arbitrary CPI Target
If a program accepts an external program ID as an argument (instead of hardcoding the expected target), an attacker can substitute a malicious program.

**Vulnerable Pattern:**
```rust
// DANGEROUS: The program to invoke is user-supplied
pub fn execute_cpi(ctx: Context<ExecuteCpi>, program_id: Pubkey) -> Result<()> {
    let cpi_accounts = Transfer {
        from: ctx.accounts.source.to_account_info(),
        to: ctx.accounts.destination.to_account_info(),
        authority: ctx.accounts.authority.to_account_info(),
    };
    // Attacker can pass their own program_id here!
    let cpi_ctx = CpiContext::new(ctx.accounts.external_program.to_account_info(), cpi_accounts);
    token::transfer(cpi_ctx, amount)?;
    Ok(())
}
```

**Secure Pattern (Anchor):**
```rust
#[derive(Accounts)]
pub struct ExecuteCpi<'info> {
    // Anchor verifies this IS the SPL Token Program
    pub token_program: Program<'info, Token>,
}
```

## 2. Missing Signer Seeds in CPI
When a PDA needs to sign a CPI call, the program must pass the correct seeds. If seeds are incorrect or missing, the CPI will fail—but more dangerously, if seeds are derived from user input without validation, attackers can craft seeds that resolve to a different PDA they control.

**Audit Checklist:**
- Ensure `CpiContext::new_with_signer` is used when a PDA must sign.
- Verify that the seeds passed to `invoke_signed` exactly match the seeds used to derive the PDA.
- Check that the bump seed is canonical (stored on-chain at init, not recalculated).

## 3. Re-entrancy via CPI
Unlike Ethereum, Solana's runtime prevents direct re-entrancy into the same program. However, indirect re-entrancy (Program A → Program B → Program A) is possible and can be exploited if state is read before a CPI and assumed unchanged after.

**Audit Checklist:**
- Look for patterns where account data is read, a CPI is made, and then the pre-CPI data is used for logic.
- Ensure all state mutations happen either entirely before or entirely after a CPI call.
- Flag any "check-effect-interaction" pattern violations.

## 4. Insufficient Remaining Accounts Validation
Programs that forward `remaining_accounts` to CPIs without validation allow attackers to inject malicious accounts into the call chain.

**Audit Checklist:**
- Verify that any use of `ctx.remaining_accounts` validates each account's owner, key, or other properties before passing to a CPI.
