# Basin (Stable2) — GRADING

Official: **2 High, 2 Medium.** (Lean target — good confound control vs. bug-dense ones.)

## Scorecard
| My hypothesis | Result |
|---|---|
| S2 LUT-boundary non-convergence in calcReserveAtRatioSwap (Med, lead) | **HIT → M-01** (extreme ratios from `getRatiosFromPriceSwap` → oversized Newton steps, no convergence). Predicted the exact function and mechanism; adjacent M-02 is its sibling. |
| S1 calcLpTokenSupply silent non-convergence (Med) | **Partial.** Right theme (non-convergence) but wrong function — real bug was LUT-driven in the reserve calc, not the LP-supply loop. |

Missed: **H-01** (WellUpgradeable `_authorizeUpgrade` missing `onlyOwner` —
file not read, coverage) and **H-02**.

## The units blind spot, one layer deeper (H-02)
**H-02: `decodeWellData` assigns `decimal1` wrong — it checks `decimal0 == 0`
twice instead of `decimal1 == 0`.** This is a **decimals bug — my #1 class —
and I missed it AGAIN**, this time by *over-clearing*: I box-checked the scaling
MATH that USES the decimals (getScaledReserves, the `10**(18-decimals)` round
trip) and declared decimals "consistent," but the bug is in `decodeWellData`,
the function that PRODUCES the decimals — which I never opened. I trusted an
upstream helper.

## The compounded lesson (units + coverage + over-clearing, unified)
"Clear the units" is only valid if you read the function that **sources** each
unit — the decoder, the config setter, the oracle's decimals() — not just the
math that consumes it. Three contests now (BakerFi, Revert Lend, Basin) had a
units/decimals High I missed by trusting a value's source instead of reading it.
**Method fix: the unit-audit pass must trace every unit to its origin function
and READ that function. An unread source = an uncleared unit.**

## Batch-final calibration read
On a lean 4-finding target I landed 1 clean Medium (correctly, as a flagged
lead) + 1 partial, and missed 2 Highs — one by coverage (H-01), one by the
persistent units-source blind spot (H-02). Consistent, honest signal: real skill
on convergence/AMM mechanics; the durable weakness is units-at-their-source.
