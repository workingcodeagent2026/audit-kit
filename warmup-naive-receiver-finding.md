# [High] `flashLoan` lets anyone charge a victim receiver a fixed fee without its consent, draining it fee-by-fee

*Warm-up — Damn Vulnerable DeFi v4 `NaiveReceiverPool.sol` (+ `FlashLoanReceiver`).
Verifiable against the public solution. Class: privileged/costly action lacks
beneficiary authorization (griefing with attacker-set repetition).*

## Summary
`flashLoan` charges a fixed 1e18 WETH fee (`:12`, `:60`) and can be called by
**anyone** naming **any** `receiver`. The victim `FlashLoanReceiver` repays
`amount + FIXED_FEE` on each call, so an attacker forces it to take 0-value (or
any) loans repeatedly until its entire balance is siphoned into `feeReceiver` —
without the receiver ever asking for a loan.

## Finding description
```solidity
if (receiver.onFlashLoan(msg.sender, address(weth), amount, FIXED_FEE, data) != CALLBACK_SUCCESS)
    revert CallbackFailed();
uint256 amountWithFee = amount + FIXED_FEE;                       // :56
weth.transferFrom(address(receiver), address(this), amountWithFee);  // :57 — receiver pays the fee
deposits[feeReceiver] += FIXED_FEE;                              // :60
```

Nothing authenticates that `receiver` consented to this loan. A conforming
receiver returns `CALLBACK_SUCCESS` for any caller, so a third party can invoke
`flashLoan(victim, weth, 0, "")` and the victim pays 1 WETH each time. With a
victim holding 10 WETH, ten calls (batchable via the pool's `Multicall`) drain it.

**Deeper lead I would confirm before finalizing (scoping honesty):** the pool
mixes a `Multicall` with a trusted-forwarder `_msgSender()` (`:80-86`) that reads
the caller from the last 20 bytes of calldata. If a `withdraw`-style function
uses `_msgSender()` for authorization, an attacker can likely batch a call
through the forwarder that *spoofs* `_msgSender()` to `feeReceiver`/`deployer`
and withdraw accumulated deposits directly — a full pool drain rather than just
receiver griefing. Confirming requires `BasicForwarder` and the withdraw path,
not shown here; I flag it as the higher-impact variant rather than asserting it.

## Impact
**High.** As shown: unauthorized, repeatable draining of any flash-loan receiver's
balance via forced fees. Potentially critical (full pool drain) if the
forwarder/`_msgSender` spoofing lead confirms.

## Proof of concept (receiver griefing, fully evidenced)
Victim `FlashLoanReceiver` holds 10 WETH.
1. Attacker batches 10× `flashLoan(victim, address(weth), 0, "")` via the pool's
   `Multicall`.
2. Each call: victim receives 0, its `onFlashLoan` returns success, pool pulls
   `0 + 1e18` from the victim; `deposits[feeReceiver] += 1e18`.
3. After 10 calls the victim's 10 WETH is gone.

## Recommended mitigation
Require the receiver (or an authorized initiator) to have requested the loan —
e.g. authenticate `msg.sender` as the borrower/beneficiary, or have the receiver
verify `initiator` in `onFlashLoan`. Separately, do not combine a `Multicall`
with a trusted-forwarder `_msgSender()` that trusts trailing calldata; it breaks
sender authentication for every function that relies on it.
