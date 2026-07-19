# Revert Lend research — BLIND predictions

Pass 3/4. Target: 2024-03-revert-lend (Uniswap V3 position lending). Read
V3Oracle.getValue/_getReferenceTokenPriceX96 and V3Vault liquidate/
_calculateLiquidation/_updateGlobalInterest. Partial coverage (11 files; skipped
transformers, automators, InterestRateModel) — honest note. Oracle is our #1
drill class.

## Unit-audit / oracle-checklist result
V3Oracle is *robust*: Chainlink+TWAP cross-verification with `maxDifference`,
`_checkPoolPrice` against the actual pool (manipulation guard), decimals handled
(`10**referenceTokenDecimals ... / 10**feedConfig.tokenDecimals`). No decimal
mismatch found. Debt uses `Rounding.Up` (favors protocol — correct direction).
The oracle is not the weak point; this is a mature feed.

## Hypotheses (low confidence — hard target)

**R1 (Medium) — Uncollected Uni V3 fees counted as collateral.** `getValue`
computes `value = price0*(amount0 + fees0)/Q96 + price1*(amount1 + fees1)/Q96`.
Uncollected fees (`fees0/fees1`) are included in collateral value. If a position
owner can inflate uncollected fees (self-directed swaps through their own
position's range) or those fees are otherwise not reliably seizable, collateral
is overvalued → over-borrow / harder liquidation. Concrete line.

**R2 (Low/Med) — liquidation exact-debtShares match enables grief-revert.**
`if (debtShares != params.debtShares) revert DebtChanged();` after
`_updateGlobalInterest` accrues interest — a liquidator's tx reverts if debt
moved between quote and submit. Frontrun griefing; low.

## Leads NOT claimed
- Interest/exchange-rate rounding: looked correct (debt rounds up). No claim.
- `transform`/reentrancy in the transformers: files not read. Flag only.

## Note
Mature target; I expect a low score and coverage is partial (budget). Testing
whether the oracle checklist correctly *clears* a robust oracle (avoiding false
positives) — a negative result is still calibration data.
