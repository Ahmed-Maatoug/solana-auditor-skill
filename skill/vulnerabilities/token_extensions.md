# Token-2022 (Token Extensions) Security Check

Token-2022 is Solana's next-generation token standard. It introduces powerful extension features that create entirely new attack surfaces that most auditors are not yet trained to detect.

## 1. Transfer Hook Exploits
Token-2022 allows mints to define a **Transfer Hook** — a custom program that executes on every token transfer. This is a powerful feature but introduces critical risks.

**Attack Vector:** A malicious mint owner deploys a transfer hook program that:
- Silently skims a percentage of every transfer to an attacker-controlled account
- Blocks transfers to specific addresses (censorship)
- Reverts transfers under certain conditions (creating a honeypot token)

**Audit Checklist:**
- When interacting with Token-2022 tokens, verify whether the mint has a transfer hook extension enabled.
- If your protocol accepts arbitrary Token-2022 mints, ensure you account for the fact that transfers may fail or have side effects.
- Check that CPI calls to `spl_token_2022::instruction::transfer_checked` include the required additional accounts for the transfer hook.

```rust
// When checking if a mint uses transfer hooks:
use spl_token_2022::extension::transfer_hook::TransferHook;

let mint_data = ctx.accounts.mint.to_account_info().try_borrow_data()?;
let mint = StateWithExtensions::<Mint>::unpack(&mint_data)?;
if let Ok(hook) = mint.get_extension::<TransferHook>() {
    // This mint has a transfer hook — verify the hook program is trusted!
    let hook_program_id = Option::<Pubkey>::from(hook.program_id);
    require!(hook_program_id == Some(TRUSTED_HOOK_PROGRAM), ErrorCode::UntrustedHook);
}
```

## 2. Permanent Delegate Abuse
Token-2022 allows mints to set a **Permanent Delegate** — an authority that can transfer or burn tokens from ANY holder's account at any time.

**Attack Vector:** A token creator sets themselves as permanent delegate, waits for users to accumulate tokens, then drains all holder accounts.

**Audit Checklist:**
- Flag any Token-2022 mint with the `PermanentDelegate` extension as HIGH RISK.
- If your protocol holds Token-2022 tokens, verify that the mint does NOT have a permanent delegate.
- Warn users that permanent delegate tokens can be seized at any time.

## 3. Transfer Fee Accounting Errors
Token-2022 mints can charge a fee on every transfer. If a protocol does not account for this fee, the received amount will be less than expected, potentially breaking invariants.

**Vulnerable Pattern:**
```rust
// DANGEROUS: Assumes received amount equals sent amount
token::transfer(cpi_ctx, 1000)?;
vault.total_deposits += 1000;  // Actual received might be 990 after fee!
```

**Secure Pattern:**
```rust
// Check actual balance change
let balance_before = ctx.accounts.vault_token.amount;
token_2022::transfer_checked(cpi_ctx, amount, decimals)?;
ctx.accounts.vault_token.reload()?;
let actual_received = ctx.accounts.vault_token.amount - balance_before;
vault.total_deposits += actual_received;
```

## 4. Confidential Transfer Risks
Token-2022's confidential transfer extension encrypts transfer amounts using zero-knowledge proofs. Protocols that rely on reading on-chain balances will break.

**Audit Checklist:**
- If a protocol reads `token_account.amount` for logic, verify it handles confidential transfer mints where `amount` may be zero (all funds in the confidential "pending" or "available" balance).
- Flag any protocol that assumes `TokenAccount.amount` reflects the full balance when Token-2022 mints are involved.

## 5. Non-Transferable / Soul-Bound Tokens
Token-2022 supports non-transferable tokens. If a protocol expects to transfer a user's tokens (e.g., for staking or collateral), non-transferable tokens will cause the instruction to fail.

**Audit Checklist:**
- If a protocol accepts arbitrary mints, verify it handles the case where transfers are blocked by the `NonTransferable` extension.
