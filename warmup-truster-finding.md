# [High] `flashLoan` executes an attacker-controlled call from the pool's own context, allowing full drain

*Warm-up — Damn Vulnerable DeFi v4 `TrusterLenderPool.sol`. Verifiable against
the public solution. Class: trusting caller-supplied external-call parameters.*

## Summary
`flashLoan` makes an arbitrary call to a caller-supplied `target` with
caller-supplied `data`, executed **by the pool**. An attacker sets `target` to
the token and `data` to `approve(attacker, balance)`, granting themselves an
allowance over the pool's entire balance, then transfers it out — with a
loan `amount` of 0 so the repayment invariant trivially holds.

## Finding description
`TrusterLenderPool.sol:20-35`:

```solidity
token.transfer(borrower, amount);
target.functionCall(data);                       // line 28 — attacker controls both
if (token.balanceOf(address(this)) < balanceBefore) revert RepayFailed();
```

`target` and `data` are unvalidated attacker input, and `functionCall` runs in
the pool's context (`msg.sender == pool`). Nothing restricts `target` to the
borrower or forbids it being the token contract. The balance check on line 30
only compares before/after balances — it does not detect an *approval*, which
moves no tokens until later.

## Impact
**High — total, unconditional theft of pool funds.** Any address drains the
full balance in two transactions (or one, batched), permissionlessly.

## Proof of concept
Pool holds 1,000,000 DVT.
1. Attacker calls
   `flashLoan(0, attacker, address(token), abi.encodeCall(token.approve, (attacker, 1_000_000e18)))`.
   - `amount = 0` → the transfer is a no-op, `balanceBefore == balanceAfter`,
     line 30 passes.
   - line 28 executes `token.approve(attacker, 1_000_000e18)` as the pool.
2. Attacker calls `token.transferFrom(pool, attacker, 1_000_000e18)`. Pool empty.

## Recommended mitigation
Do not make arbitrary calls to caller-controlled targets. Flash-loan repayment
should use the ERC-3156 `onFlashLoan` callback on the *borrower* only, or at
minimum forbid `target == address(token)` and enforce `msg.sender == borrower`.
Prefer balance-delta accounting that requires `amount + fee` returned via
`transferFrom` from the borrower, never a free-form call.
