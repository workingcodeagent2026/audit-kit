# BakerFi research — BLIND predictions (written before reading the findings)

Target: Code4rena BakerFi Invitational (2024-05). Cold review of the oracles
and Vault via our economic-truth methodology. These are my hypotheses **before**
opening the official report; the grading file records how they scored.

## Ranked hypotheses

**H1 (High) — PythOracle ignores the confidence interval and uses `getPriceUnsafe`.**
`getLatestPrice()` → `_getPriceInternal(0)` → `_pyth.getPriceUnsafe(_priceID)`
(`PythOracle.sol`). No staleness bound and no use of `price.conf`. A wide/
uncertain or stale Pyth price is accepted as exact, mispricing collateral.

**H2 (High) — Missing L2 sequencer-uptime check in the Chainlink oracles.**
BakerFi deploys to Arbitrum, Optimism, Base. `WstETHToETHOracle`/`ETHOracle`
call `latestRoundData()` with no Chainlink L2 Sequencer Uptime Feed check.
During a sequencer outage a stale price is served as fresh → mispriced
leverage/liquidation.

**H3 (High, conditional) — WstETH oracle may consume a stETH/ETH feed as if wstETH/ETH.**
`WstETHToETHOracle` names its feed `_stETHToETHPriceFeed` and returns it directly
as the wstETH/ETH price. stETH and wstETH differ by the wrap ratio (>1). If the
deployed feed is stETH/ETH, wstETH collateral is undervalued/overvalued by that
ratio. Conditional on which feed address is wired in production; flag to verify.

**H4 (Medium) — Pyth `int64`→`uint64` cast without a positivity check.**
`uint64(price.price)` with no `price.price > 0` guard. A negative price wraps to
a huge uint. Chainlink oracles here *do* check `answer <= 0`; Pyth does not.

**H5 (Medium) — `getLatestPrice()` has no staleness check; only `getSafeLatestPrice` does.**
Any caller using `getLatestPrice` (all oracles) gets an unbounded-age price.
Depends on whether critical paths call the unsafe variant.

**H6 (Low) — Pyth exponent underflow for `expo < -18`.**
`_PRECISION - uint32(-price.expo)` underflows/reverts if a feed exponent is more
negative than -18. DoS on such feeds. Edge, feed-dependent.

**H7 (needs more code) — Vault first-depositor share inflation / rounding.**
Standard ERC4626-style risk; I did not fetch the full `deposit`/RebaseLibrary
math, so I am NOT claiming it — flagged only as the next place to look.

## Honesty notes
- H3 and H5 are explicitly conditional — I'm recording uncertainty, not asserting.
- H7 is a lead, not a finding. No claim without the code.
- Success criterion: do H1–H2 (my confident Highs) match real High/Med findings?
