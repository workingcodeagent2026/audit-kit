# [High] `claimRewards` pays out per-iteration but records claimed-status once, allowing repeated claims of the same reward in a single call

*Warm-up — Damn Vulnerable DeFi v4 `TheRewarderDistributor.sol`. Verifiable
against the public solution. Class: payout loop and claimed-accounting are not
in lockstep — the on-chain twin of our trap #1 (fake rewards: promise vs.
actual payout diverge).*

## Summary
`claimRewards` transfers the reward on **every** loop iteration (`:107`) but
only commits the "claimed" bitmap when the token changes or on the final
iteration (`:82-99`), accumulating repeated claims of the same batch into a
single idempotent bit. An attacker submits the same valid claim many times in
one `inputClaims` array: each pass transfers tokens, but the duplicate-detection
sees only one set bit and passes. The distributor is drained.

## Finding description
For each entry the loop verifies a Merkle proof and immediately pays out:

```solidity
inputTokens[inputClaim.tokenIndex].transfer(msg.sender, inputClaim.amount);  // :107 — every iteration
```

But the double-claim guard runs in `_setClaimed` (`:111-119`), which is only
invoked on a token switch (`:82-86`) or the last element (`:96-99`). Within a
run of same-token claims the code does:

```solidity
bitsSet = bitsSet | 1 << bitPosition;   // :92 — idempotent for a repeated batch
amount += inputClaim.amount;            // :93
```

Repeating the *same* `batchNumber` ORs the same bit, so `bitsSet` never reflects
that the reward was counted N times. `_setClaimed` then checks
`currentWord & newBits` once and sets one bit — while `transfer` has already
fired N times. The claimed-ledger and the payout loop are not in lockstep.

## Impact
**High — full drain of the distributor's token balances.** Any address on a
single valid leaf can claim its reward arbitrarily many times in one transaction.

## Proof of concept
Attacker is entitled to one legitimate claim of `amount` for `(token, batch b)`.
1. Build `inputClaims` = the same valid claim repeated K times (same batch b,
   same amount, same proof), all `tokenIndex` pointing at one token.
2. Call `claimRewards`. Iterations 1..K each verify the (identical) proof and
   `transfer(msg.sender, amount)` — K payouts.
3. `_setClaimed` runs once at the end, sets bit b once, subtracts `amount * K`
   from `remaining` (or underflows/succeeds depending on balance). Attacker
   walks away with `K * amount`.

## Recommended mitigation
Mark claimed **before** paying, per individual claim: check-and-set the bit for
each `(token, batch)` immediately, then transfer. Do not batch the bitmap commit
across iterations, and reject an `inputClaims` array containing a duplicate
`(tokenIndex, batchNumber)`. Follow checks-effects-interactions: record the
claim, then send the tokens.
