# Revert Lend — GRADING

Official: **6 High, 27 Medium** (large scope, target-rich — yet I scored 0).

## Scorecard
| My hypothesis | Result |
|---|---|
| R1 uncollected fees as collateral (Med) | **Weak/adjacent.** Fee-accounting bugs exist (M-17) but not my exact getValue-collateral claim. No clean match. |
| R2 liquidation exact-debtShares grief (Low) | **Miss.** |
| "Oracle is robust, cleared" (my negative call) | **WRONG.** The oracle had M-07 (decimals overflow), M-19 (manipulation), M-25 (asymmetric diff), **M-27 (missing L2 sequencer check)**. |

**Clean hits: 0.**

## The real lesson: over-CLEARING (opposite of over-claiming)
I declared V3Oracle "robust, not the weak point" — and it had 4+ findings. Worst:
**M-27 missing L2 sequencer check is literally item #4 on my oracle checklist**,
and **M-07 decimals-overflow is item #1's neighbor** — I *have* these boxes and
still missed them because I ran the checklist as **vibes ("looks robust")
instead of ticking each box yes/no against this code.** The checklist existed
precisely to prevent this and I didn't execute it mechanically.

Also missed **H-05: TWAP tick fails to round negative deltas** — a rounding/unit
bug in the oracle I read and cleared. Units/rounding miss *again*, in the exact
file I inspected.

## Method fix (enforcing, not just noting)
**Run the oracle checklist as a literal yes/no table, one row per feed, written
down** — never summarize as "robust." For THIS oracle the honest table would
have been:
- decimals normalized? partially (overflow at high decimals → M-07)
- min/max bounds? (unchecked)
- staleness? — L2 **sequencer check? NO → M-27**
- TWAP negative-tick rounding? NO → H-05
"Looks careful" is not an answer to any box. A cleared oracle requires every box
explicitly ticked in writing.

## Honest read
0 hits on a 33-finding target — my worst outcome relative to opportunity. Cause:
under-coverage (budget) PLUS over-clearing a feed I should have box-checked. The
calibration pendulum swung from over-hedging (DYAD) to over-clearing (here). The
fix is the same discipline both ways: assert exactly what mechanical checks show,
neither hedged nor hand-waved.
