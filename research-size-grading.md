# Size — GRADING (the payoff)

Official: **4 High, 13 Medium.**
- H-01 swap fee in sellCreditMarket; H-02 repay/liquidateWithReplacement race;
  H-03 collateral-remainder cap uses full CR (130%) not excess (30%);
  **H-04 liquidator reward uses futureValue (6-dec debt) not debtInCollateralToken
  (18-dec) → reward off by 1e12x.**

## Scorecard
| My hypothesis | Result |
|---|---|
| SZ1 reward mixes 6-dec debt & 18-dec collateral (High) | **CLEAN HIGH HIT → H-04.** Exact root cause, exact 1e12 factor, exact fix (use debtInCollateralToken). |
| SZ2 no incentive underwater (Med) | **Unclear/partial** — not a judged H/M as I framed it (likely by-design in Size). |
| SZ3 conversion decimals (lead) | Appropriately flagged, not asserted. |

## THIS is the payoff of the whole training arc
H-04 is a **units-at-their-source liquidation-reward decimal mismatch** — the
EXACT class that was our top-severity miss in BakerFi, Canto, Revert Lend, and
Basin (0-for-4). This time, with:
- the researched **units playbook** (pattern #3: cross-decimal non-normalization),
- the **"start at the liquidation/money-entry function"** rule (Ondo lesson),
- **claim-what-you-can-verify** (DYAD lesson),
…I caught it as a confident High, on a blind contest, tied to the lines. The
weakness that dogged 7 rounds converted into a clean hit. The method + research
worked, empirically.

## Honest misses
- **H-03 (remainder cap uses 130% not 30%):** I READ that exact line
  (`collateralRemainderCap = mulDivDown(debtInCollateralToken, crLiquidation,
  PERCENT)`) and didn't flag it — a SECOND bug in the same function I audited.
  The "when one line/param is buggy, check its neighbors" rule (AI Arena H-06)
  applies: I found H-04 two lines above and stopped.
- H-01, H-02: market/repay files I didn't read (coverage — 32-file target).

## Read
1 clean High on the exact class we set out to fix. Not full marks (missed 3
Highs, 2 by coverage, 1 by stopping at the first bug) — but the headline is real:
**the units-at-source weakness is now demonstrably catchable with the researched
playbook.** Upgrade the units class ❌→🔶 (caught once under blind conditions;
keep drilling to make it reliable).
