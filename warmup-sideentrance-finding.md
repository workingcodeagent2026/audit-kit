# [High] `flashLoan` trusts raw ETH balance while `deposit` mints a withdrawable claim on the same ETH

*Warm-up — Damn Vulnerable DeFi v4 `SideEntranceLenderPool.sol`. Verifiable
against the public solution. Class: two accounting systems measuring the same
value, played against each other (our "can accounting drift from reality?").*

## Summary
`flashLoan` considers itself repaid whenever the pool's raw ETH balance is
restored. But `deposit()` credits `balances[msg.sender]` — a separate, withdrawable
ledger — using that same ETH. An attacker borrows the whole pool, deposits it
back inside the flash-loan callback (satisfying the balance check *and* crediting
their own balance), then withdraws it all.

## Finding description
The pool tracks value two ways: the raw `address(this).balance`, and the
`balances` mapping (`:12`). `flashLoan` (`:35-43`) only checks the first:

```solidity
uint256 balanceBefore = address(this).balance;
IFlashLoanEtherReceiver(msg.sender).execute{value: amount}();
if (address(this).balance < balanceBefore) revert RepayFailed();
```

`deposit()` (`:19-24`) increases `balances[msg.sender]` while returning ETH to
the contract — so a repayment made *via deposit* restores the raw balance
(check passes) yet simultaneously mints the attacker a claim equal to the loan.
`withdraw()` (`:26-33`) then pays that claim out. The two ledgers are never
reconciled against each other.

## Impact
**High — full, unconditional drain of pool ETH** by any caller in a single
transaction.

## Proof of concept
Pool holds 1,000 ETH.
1. Attacker (a contract) calls `flashLoan(1000 ether)`.
2. In `execute()`, attacker calls `deposit{value: 1000 ether}()`.
   - Raw balance returns to 1,000 → line 40 check passes.
   - `balances[attacker] = 1000 ether`.
3. After `flashLoan` returns, attacker calls `withdraw()` → receives 1,000 ETH.
   Pool empty.

## Recommended mitigation
Don't let flash-loan repayment be satisfiable by a state-changing path that also
creates a claim. Either disallow `deposit` during an active flash loan (reentrancy
guard / flag), or account the loan explicitly (require the borrower return
`amount` via a dedicated repay path, not by touching the shared deposit ledger).
