# Scorecard — the trajectory

One row per blind pass. Track the curve, not just the count. Hit = matched a
real High/Medium with correct mechanism; partial = right line/area, wrong
specifics or hedged.

| # | Contest | Findings (H/M) | My hits | My misses | Notable |
|---|---|---|---|---|---|
| 1 | 2024-05-bakerfi | 4H/8M | 0 | ~12 | Read the decimals-High line and missed it. Blind spot #1: units. |
| 2 | 2024-01-canto | 2H/2M | 1 Med + 1 partial | 2H | Coverage gate worked (1 file). Missed block-vs-timestamp High = units again. |
| 3 | 2024-04-dyad | 10H/9M | 2H + 1M | ~15 | First confident-High hit (unit-audit pass). Confound: buggy target. Hedged a verifiable High. |
| 4 | 2024-03-pooltogether | 1H/8M | 0 + 1 partial | ~8 | Mature target; under-covered (budget). Missed M-03 in code I read → new "predictor vs executor" class. |
| 5 | 2024-02-ai-arena | 8H/9M | 2H + 1H-lead + 1 partial | ~13 | Best hit-quality. "Claim what you can verify" produced 2 confident Highs (H-04, H-03). Confound: bug-dense. Missed 2nd bug on a line I read (H-06 uint8). |
| 6 | 2024-03-revert-lend | 6H/27M | 0 | ~33 | Worst outcome vs opportunity. OVER-CLEARED a robust-looking oracle that had 4+ findings incl. M-27 sequencer (on my checklist). Lesson: run checklists as written yes/no boxes, not vibes. |

## Curve read (honest)
0 → 1 → 3 hits. Real upward trend, BUT round 3's target had 19 findings vs.
round 2's 4 — bugginess confound not yet controlled. Next: a ~4-finding contest
to test if gains hold on a lean codebase.

## Standing weaknesses (open)
- Miss: double-counting across accounting sets (DYAD H-01).
- Miss: liquidation-incentive math (DYAD H-02/H-07, M-01/M-02/M-05).
- Miss: frontrun/self-liquidation flash-loan classes (DYAD H-04/H-10).
- Calibration: swung from over-claiming narrative Highs (R1-2) to over-hedging
  verifiable Highs (R3). Target: claim exactly what the read code proves.
