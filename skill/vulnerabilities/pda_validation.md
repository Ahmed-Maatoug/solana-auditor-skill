# PDA Validation Check

When auditing Program Derived Addresses (PDAs), verify the following vectors:

## 1. Missing Seed Validation
PDAs are derived using a set of seeds and the program ID. If an instruction accepts a PDA but does not verify the seeds used to create it, an attacker can pass in a malicious account.

**Anchor Mitigation:**
Ensure the `#[account(seeds = [...], bump)]` macro is used correctly. 
If manual validation is used, ensure `Pubkey::find_program_address` is called and compared against the provided account key.

## 2. Canonical Bump Verification
When a PDA is created, multiple valid bumps might exist, but only the highest bump (the "canonical bump") is secure. Using a non-canonical bump allows attackers to create multiple PDAs with the same seeds.

**Anchor Mitigation:**
Anchor handles canonical bumps automatically in modern versions when using `init` or `seeds` with `bump`. Ensure the code does not manually supply a user-provided bump without verifying it against `find_program_address`.

## 3. Initialization State
Ensure PDAs cannot be re-initialized. 

**Anchor Mitigation:**
Use the `init` constraint. If `init_if_needed` is used, flag it as a severe warning, as it can lead to state override attacks if not implemented with extreme caution.
