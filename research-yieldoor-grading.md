# Yieldoor (SHERLOCK) — GRADING — platform-generalization test

Judged findings (Sherlock uses "Sponsor Confirmed/Will Fix" not H/M labels).
Confirmed (9): isLiquidateable base calc; high-leverage vs liq-check contradiction;
secondary-tick modulo → div0; collectFees wrong tick → fee loss/lockup;
observation-index overflow DoS; **"Liquidation fee will not be claimed due to
incorrect decimal handling"**; withdrawal underflow lock; uninitialized
feeRecipient; deposit no multi-hop exactOutput. Disputed (incl.): "Insufficient
Decimal"; various Strategy tick/price issues.

## Scorecard
| My hypothesis | Result |
|---|---|
| Y1 `liquidatePosition` divides by `.decimals()` not `10**decimals` (High) | **CONFIRMED HIT → "Liquidation fee will not be claimed due to incorrect decimal handling."** My #1 prediction, exact, on a NEW platform. |
| Y3 PriceFeed raw `answer`, no decimal normalization | **Adjacent → "Insufficient Decimal" (Sponsor DISPUTED / won't fix).** Submitted-tier, not rewarded. |
| Y2 PriceFeed staleness ignored (High) | **Not judged valid.** No confirmed oracle-staleness finding — see platform nuance below. |
| Y4 no min/max, no sequencer | **Not judged valid.** |

## The win
**Y1 — the decimals-count-vs-scaling bug — is a CONFIRMED Sherlock finding.** The
units class (our former #1 weakness) transferred cleanly to a different platform
and landed my headline confident prediction. The units playbook generalizes.

## Platform-generalization lesson (Sherlock rules differ from C4)
My oracle-checklist Highs (Y2 staleness, Y4 bounds/sequencer) were NOT rewarded.
Likely cause: the PriceFeed is **owner-configured** (setChainlinkPriceFeed is
onlyOwner), and Sherlock has strict **admin-trust** rules — findings that require
admin misconfiguration or assume trusted-admin failure are frequently judged
invalid ("won't fix"). Even "Insufficient Decimal" (a real observation) was
DISPUTED. **Calibration for Sherlock: down-weight admin-trusted-config findings;
the checklist boxes that are Highs on C4 may be invalid on Sherlock.** Platform
rules are part of the target.

## Misses (coverage-attributable)
Most confirmed findings (isLiquidateable base calc, tick modulo/div0, collectFees
tick, observation overflow, withdrawal underflow) live in Strategy/Leverager
TICK MATH and `isLiquidateable` — functions I did NOT deep-read (I covered
liquidatePosition + PriceFeed). Declared-uncovered → predictable misses.

## Read
First non-C4 contest: 1 confirmed hit on my headline units prediction + 1
adjacent-disputed, with a genuine platform-rules lesson (admin-trust judging).
The method generalizes; the calibration layer is now platform-aware.
