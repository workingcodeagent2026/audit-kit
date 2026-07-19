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
| 7 | 2024-07-basin | 2H/2M | 1M (lead) + 1 partial | ~4 | Lean target. Hit LUT non-convergence (M-01) as flagged lead. Missed H-02 decimals-decode — units blind spot ONE LAYER DEEPER (cleared math, didn't read the decoder). |

## Batch 2 (playbooks + subagent research active)
| # | Contest | Findings (H/M) | My hits | Notable |
|---|---|---|---|---|
| 8 | 2024-05-loop | 1H/0M | **1H (clean)** | 1-for-1, 0 false positives. Full coverage + balance-delta check + confident claim. Warm-up validated the method. |
| 9 | 2024-03-ondo-finance | 1H/4M | 0 | Coverage mis-aim: drilled rOUSG rebase math (correctly cleared, no FP) but all findings were in OUSGInstantManager (USDC-peg mint) I didn't read. Lesson: start at the money-ENTRY function. |
| 10 | 2024-06-size | 4H/13M | **1H (clean)** | 🎯 PAYOFF: SZ1→H-04, the units-at-source liquidation-reward decimal mismatch (6-dec vs 18-dec, 1e12x) — the EXACT class missed 0-for-4 before. Researched units playbook + start-at-liquidation + claim-what-you-verify caught it blind. Missed H-03 (2nd bug, same fn) + H-01/02 (coverage). |

## Batch 3 (coverage-stress test — coverage-first protocol)
| # | Contest | Findings (H/M) | My hits | Notable |
|---|---|---|---|---|
| 11 | 2024-03-abracadabra | 4H/16M | 1H + 1M (+1 FP) | 29 files. Coverage-first executed: mapped all, read value boundary, DECLARED uncovered. AB1→H-04 (LP spot-oracle) clean. AB2→M-10 (missing return, over-rated sev). AB3 flashLoan &&→ FALSE POSITIVE (unverified logic-High). Forfeited 2H+13M in declared-uncovered files (predictable). Coverage RECURSES to function level (missed H-01/H-02 in a file I "read"). |

## Batch 2 read (playbooks + subagent research)
3 passes: loop 1/1 clean · ondo 0 (coverage mis-aim) · size 1 clean (THE units
class, caught blind for the first time). The research→playbook→apply loop
demonstrably converted our #1 durable weakness into a caught High. Remaining
gaps are now COVERAGE (read all money-entry files) and STOPPING-AT-FIRST-BUG
(check neighbors), not the units blind spot itself.

## Batch summary (passes 4–7, the /goal loop)
7 blind contests total. Curve: 0 → 1 → 3 → 0 → 3 → 0 → 1(+partial). Confounds are
real (target bug-density ranged 4–33 findings). **The single durable weakness
across ALL rounds: units/decimals at their SOURCE** — top-severity in BakerFi,
Canto, Revert Lend, Basin; missed each time by trusting a value's origin instead
of reading it. Every other class is intermittently caught. Next drill: nothing
but unit-source tracing until it stops being the recurring miss.

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
