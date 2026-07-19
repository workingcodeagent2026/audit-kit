# Canto research — GRADING (predictions vs. official findings)

Official: **2 High, 2 Medium.**
- **H-01** `update_market` queries gauge weight with a **block number where the
  gauge controller expects a timestamp** → wrong/zero rewards.
- **H-02** epoch loop uses `nextEpoch = i + BLOCK_EPOCH` instead of
  `epoch + BLOCK_EPOCH` → wrong `blockDelta` across epoch boundaries.
- **M-01** `secRewardsPerShare` scaled by 1e18 (should be ~1e27) → rounds to 0.
- **M-02** `accCantoPerShare`: divide-by-1e18 before multiply-by-1e18 → precision
  loss (~1 CANTO/distribution).

## Scorecard

| My hypothesis | Result |
|---|---|
| H1 de-whitelist DoS (High) | **Miss.** Not a judged H/M. |
| H2 reward funding/solvency (High) | **Miss.** Not judged. |
| H3 current-epoch claim vs spec (Med) | **Miss.** |
| H4 `secRewardsPerShare` scaling/TODO (Med) | **HIT → M-01.** Same exact line, correctly called it a scaling/precision defect. |
| H5 precision/truncation (Low) | **Partial → M-02.** I flagged precision generally; missed the specific div-before-mul. |

**Both real Highs: missed.** But I read the exact lines of both.

## Progress vs. BakerFi
- BakerFi: 0 hits, best was an area I flagged but didn't claim.
- Canto: **1 clean Medium hit on the exact line + mechanism (M-01)** and 1 partial
  (M-02). The coverage gate worked — single file, fully read, and both my hits
  are real. Line-level discipline paid off.

## The blind spot is now confirmed and it is specific
Both contests' #1 High was a **unit/semantic mismatch** — our own trap #2:
- BakerFi H-01: 8-decimal price used as 18-decimal.
- Canto H-01: block number passed where a **timestamp** is expected.

I read both lines and missed both, because I was hunting narrative bugs
(access-control DoS, funding solvency) — and note my two *confident Highs* were
wrong in **both** contests. My calibration is inverted: I'm overconfident on
narrative "Highs" and under-attentive to boring unit/precision bugs, which are
what actually pay. Canto H-02 (loop `i` vs `epoch`) is the same shape: a quiet
arithmetic/alignment bug in code I read.

## Method fixes (applying now)
1. **Unit audit pass (promote to first-class, not just oracles).** For *every*
   quantity and *every* cross-contract argument: what unit is this (decimals,
   block vs. timestamp, per-share vs. absolute, wei vs. token)? Does the callee
   expect that unit? This is trap #2 generalized beyond oracles — it has been
   the top High twice.
2. **Confidence inversion.** Stop labeling narrative bugs (DoS-by-governance,
   funding-trust) as confident Highs; those were 0-for-4. Treat unit/precision/
   loop-arithmetic as the high-probability High and audit them first and hardest.
3. **Trace every loop's index arithmetic explicitly.** Canto H-02 lived in the
   `while (i < block.number)` loop; write out the intended vs. actual index
   progression on paper. (I would have caught `i + BLOCK_EPOCH` vs
   `epoch + BLOCK_EPOCH`.)

## Honest standing
Two blind contests: trending up (0 → 1 solid hit + 1 partial), coverage
discipline working, and a *named, repeating* weakness (unit/semantic bugs) with
a concrete drill to fix it. Still not catching the Highs — not yet competitive,
but improving in exactly the measurable way the experiment was designed to show.
