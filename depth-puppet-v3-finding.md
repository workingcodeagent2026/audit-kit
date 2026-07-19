# [High] 10-minute TWAP is too short for the pool's liquidity, letting an attacker sustain a manipulated price and borrow far under-collateralized

*Depth drill — Damn Vulnerable DeFi v4 `PuppetV3Pool.sol`. Uses a real
manipulation-resistant pattern (Uniswap V3 TWAP), so the bug is not "spot oracle"
but the subtler, real-world mistake: **a TWAP window sized without reference to
pool liquidity.** Class: oracle manipulation cost < value extracted.*

## Summary
`PuppetV3Pool` prices collateral from a **10-minute** Uniswap V3 TWAP (`:16`,
`:59-67`). A TWAP resists manipulation only if sustaining a moved price across
the averaging window costs more than it yields. With a thin pool and a window
this short, an attacker swaps the V3 pool to a low token price, holds it for
~10 minutes (a handful of blocks), then borrows the pool's tokens at a fraction
of proper collateral — and unwinds the swap, recovering most of the manipulation
cost. Net cost ≪ value extracted.

## Finding description
`_getOracleQuote` consults the pool over `TWAP_PERIOD = 10 minutes` and quotes
linearly off the arithmetic-mean tick:

```solidity
(int24 arithmeticMeanTick,) = OracleLibrary.consult({pool: ..., secondsAgo: TWAP_PERIOD}); // :60
return OracleLibrary.getQuoteAtTick({ tick: ..., baseAmount: amount, ... });               // :61-66
```

`calculateDepositOfWETHRequired` scales the WETH deposit linearly by this quote
(`DEPOSIT_FACTOR = 3`, `:15`, `:55-57`). The security assumption is that the TWAP
cannot be cheaply moved. That assumption is a function of **two** parameters the
contract only half-controls: the averaging window (fixed at 10 min) and the
pool's liquidity depth (external, and in this deployment small relative to the
pool's token holdings).

The arithmetic-mean tick over `secondsAgo` converges toward a price the attacker
imposes and *holds*. Sustaining a large tick displacement for 10 minutes in a
thin pool is cheap: the cost is the swap's price impact + fees for the round
trip, most of which is recovered on unwind. When that cost is below the borrow's
value advantage (here, 3× under-collateralization once the quote is deflated),
the attack is profitable. A collateral factor of 3 does not cover a manipulation
that deflates the quote by an order of magnitude.

This is the on-chain form of our production lesson that **depth is not the same
as robustness**: a metric (here, a time-averaged price) can pass a naive
"is it a TWAP?" check while remaining manipulable because the window is short
relative to liquidity.

## Impact
**High — under-collateralized borrowing draining the pool's token reserves.**
An attacker with enough WETH/flash liquidity to move the pool for ~10 minutes
borrows the reserves for a fraction of their value.

## Proof of concept (mechanism; exact numbers depend on live pool liquidity)
1. Flash-borrow / supply a large WETH or token amount and swap in the V3 pool to
   push the token's price down sharply (raise token-per-WETH tick).
2. Hold the position ~10 minutes (mine/await blocks) so the `consult` over
   `TWAP_PERIOD` returns a tick reflecting the manipulated price — the average
   over the window now approximates the imposed price.
3. Call `borrow(largeAmount)`. `calculateDepositOfWETHRequired` returns a quote
   deflated ~in proportion to the price move, so the required WETH deposit is a
   small fraction of the tokens' real value.
4. Receive the tokens; unwind the swap, recovering most of step 1's cost.

## Recommended mitigation
Size the TWAP window to the pool's liquidity and the value at risk — minutes are
insufficient for a thin pool; use a substantially longer window and/or a
liquidity floor. Better: do not rely on a single DEX pool. Cross-check against an
independent oracle (e.g. Chainlink) within a deviation band, cap borrow size
relative to pool depth, and reject quotes when recent-window liquidity is below a
threshold. Treat "uses a TWAP" as necessary, never sufficient.
