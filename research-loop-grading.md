# LoopFi — GRADING

Official: **1 High, 0 Medium.**

## Scorecard
| My hypothesis | Result |
|---|---|
| L1 `_claim` uses `address(this).balance` not swap delta (High) | **CLEAN HIGH HIT → H-01.** Exact root cause, tied to lines, claimed at full severity. |
| L2 residual approval / non-standard token | Not a finding — correctly low-confidence, no false positive. |
| L3 swap-calldata validation gaps (lead) | Not a finding — appropriately flagged as a lead, not asserted. |

**1/1 High caught. 0 false positives.** (Contest had 0 Mediums; my extra
hypotheses were correctly held at low confidence — good calibration, not noise.)

## Why this worked
- **Full coverage** (1 file) — no unread-code misses possible.
- The **balance-delta-vs-total accounting check** (from the units/precision
  discipline: a value read as `address(this).balance` vs the measured
  `_fillQuote` delta) put H-01 directly in view.
- **Claim-what-you-can-verify** (DYAD lesson) → asserted L1 as a confident High
  instead of hedging.

First clean 1-for-1 on a real contest. Small target (warm-up), but the method
executed exactly as designed: full coverage + accounting-source check + confident
claim on verified code, with disciplined low confidence on the rest.
