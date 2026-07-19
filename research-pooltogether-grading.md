# PoolTogether V5 — GRADING

Official: **1 High, 8 Medium.**

## Scorecard
| My hypothesis | Result |
|---|---|
| P1 liquidatableBalanceOf ↔ transferTokensOut fee mismatch | **Partial → M-05.** Right function *pair*, wrong specific mechanism (real bug: fee balance vs TWAB supply limit, not 1-wei fee rounding). |
| P2 share-vs-asset denomination in share liquidation | **Miss.** |
| P3 `approve` not `forceApprove` | **Miss.** (Real transfer bug was M-06, missing return-value check.) |

**Clean hits: 0. Partial: 1.** Missed H-01 and 7 Mediums.

## The instructive miss (same family as BakerFi)
**M-03: `maxDeposit()` predicts the limit via `yieldVault.maxDeposit()` but
`_depositAndMint` actually deposits via `yieldVault.mint()`.** I read BOTH lines
(`_maxYieldVaultDeposit = yieldVault.maxDeposit(...)` and `yieldVault.mint(...)`)
and did not connect them. This is a **"consistency across two functions" bug** —
a predictor and an executor that use different mechanisms — the same shape as
BakerFi's decimals miss (getPrecision said 18, code returned 8). New KB class.

## Coverage confession
I did NOT satisfy the coverage gate — for batch-budget reasons I fetched only
PrizeVault's core value functions, skipping `claimYieldFeeShares` (where H-01
lived), `_maxYieldVaultWithdraw` (M-02), the permit path (M-08), and the
`Claimable`/`HookManager` abstracts (M-01 hook reentrancy). Findings in unread
code cannot be found. This is the coverage lesson re-proving itself: partial
coverage → guaranteed misses. Honest note that budget, not method, capped this.

## Read
Mature target, few clean opportunities, and I under-covered it. Result matches
my pre-registered expectation ("may score 0"). The transferable lesson is the
"predictor vs. executor" bug class — added to the knowledge base.
