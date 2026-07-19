# Diagnosis: our greatest weakness (from 10 blind contests)

## Finding: COVERAGE is the greatest weakness — and it's the binding constraint.

Sorting every miss across 10 contests by root cause:

| Coverage state | Contests | Outcome |
|---|---|---|
| Full (1 file) | Canto, LoopFi | hit / 1-for-1 clean |
| Under-covered / mis-aimed | BakerFi (4/32), PoolTogether, Revert Lend (~4/11), Ondo (wrong file) | **all 0 hits** |
| Partial | DYAD, AI Arena, Basin, Size | hits ∝ how much of the value path was read |

**Every zero-hit round was a coverage failure.** Ondo = 0/5 purely because I read
the rebasing token, not the mint manager where all 5 bugs were. Revert Lend =
0/33, under-covered. BakerFi = 3 Highs in unread files.

Coverage GATES the method: the best playbook catches nothing in unread code. Our
Size units-High only happened because I read the liquidation file. The ceiling of
every pass equals the code opened.

## Why coverage fails (three mechanisms)
1. **Budget-selective fetching** — pull a few functions, silently leave files
   unread, report as if fully audited.
2. **Mis-aiming** — drawn to interesting math (rebase, Newton loop) over
   money-entry functions (mint/redeem/liquidate) where bugs concentrate.
3. **Scope > budget** — big contests unreadable in one pass, uncovered part not
   declared → partial audit masquerades as complete.

## Remedy (mechanical, four parts — now in METHODOLOGY/LOOP)
1. **Coverage map FIRST:** one line per in-scope file ("what value does this
   move") before any prediction. Unwritten line = visible gap.
2. **Money-entry ordering:** read entry points first (deposit/mint/redeem/
   withdraw/liquidate/swap), then their math, then config/periphery.
3. **Scope–budget match + honest declaration:** commit to full multi-pass read OR
   scope to a subsystem and DECLARE what's uncovered. Silent partial = the failure.
4. **Track coverage % per pass** in the scorecard: a 0-hit at 30% coverage is a
   coverage failure, not a skill failure — diagnose separately.

## The DEEPER weakness underneath (revealed only once coverage is controlled)
At FULL coverage I still missed read-code bugs: Canto (block-vs-timestamp, loop
off-by), and Size H-03 (remainder cap — TWO LINES from the H-04 I caught, but I
stopped at the first bug). This is **read-but-missed / stopping-at-first-bug**:
the true "can you SEE the bug" skill, masked whenever coverage is the bottleneck.
Its remedy: **neighbor-sweep** — when one line/param is buggy, audit every
adjacent line and every other parameter of that function before moving on; trace
loop-index and arithmetic per-line. Fix coverage first (biggest immediate gain),
then this is the next frontier.

## Priority
1. COVERAGE (binding constraint, most remediable — a process/discipline fix).
2. Read-but-missed / neighbor-sweep (deeper skill, exposed after #1).
