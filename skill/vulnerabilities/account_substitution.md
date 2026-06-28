# Account Substitution Check

Account substitution is a critical vulnerability where an attacker passes a malicious account (which they own) in place of a required system or program account. 

## 1. Fake Sysvars
If a program relies on system variables (like the Clock or Rent sysvars) but does not verify the pubkey, an attacker can pass a fake account with manipulated data to alter protocol logic (e.g., faking the current timestamp to bypass timelocks).

**Anchor Mitigation:**
Anchor automatically verifies sysvars if the correct type is used in the `Accounts` struct (e.g., `Sysvar<'info, Clock>`). Flag any raw `AccountInfo` used for sysvars.

## 2. Fake SPL Token Programs
When interacting with tokens, an attacker might pass a malicious token program instead of the official SPL Token Program.

**Anchor Mitigation:**
Ensure the program constraint is used: `Program<'info, Token>`.

## 3. Fake Mints and Associated Token Accounts
An attacker might pass a token account they own but claim it is the vault, or pass a fake mint address.

**Anchor Mitigation:**
Verify the `mint` and `authority` constraints on `TokenAccount` structs.
Example: `#[account(mut, token::mint = expected_mint, token::authority = expected_authority)]`
