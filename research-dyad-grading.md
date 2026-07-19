# DYAD research — GRADING (predictions vs. official findings)

Official: **10 High, 9 Medium** (a notably buggy codebase — see confound below).

## Scorecard

| My hypothesis | Result |
|---|---|
| F1 assetPrice underflow when `dyad.totalSupply() > tvl` (High) | **DIRECT HIGH HIT → H-08.** Exact line, exact mechanism. First confident-High hit in three rounds. |
| F2 KerosineDenominator / kerosine price manipulable (Med) | **HIT → M-09.** |
| F3 `liquidate()` ignores kerosine collateral (Med) | **HIT → H-09** (I under-rated it; it's a High). |
| Lead: `withdraw` calls `oracle()` absent on kerosine vaults | **Found → H-05**, but I *hedged* it as "unsure if reachable" instead of claiming. It's a High. |
| Neighborhood: `getNonKeroseneValue - value` comparison | Adjacent to **H-06** (wrong-value comparison). |
| F4 deposit lacks vault validation (Low/Med) | **Miss-ish.** The real deposit bug was H-03 (zero-value deposit DoS), a different angle. |

**Caught: 2 Highs cleanly (H-08, H-09) + 1 Medium (M-09) + 1 High found-but-hedged (H-05).**
**Missed: H-01, H-02, H-04, H-07, H-10 and most Mediums (~4 of 19 total).**

## Trajectory across three blind rounds
- BakerFi: **0** hits.
- Canto: **1** Medium hit + 1 partial.
- DYAD: **2 High hits + 1 Medium hit + 1 High found-as-lead.**

The unit-audit-first process is what surfaced F1 — I traced the `tvl -
dyad.totalSupply()` domain and flagged the underflow *systematically*, not by
luck. That is exactly the arithmetic/range class I missed in rounds 1–2. The
fix under test worked.

## Honest confounds (do not oversell this)
1. **The target was buggier.** DYAD had 19 findings vs. Canto's 4 and BakerFi's
   12. More bugs = more surface = more chances to hit. Part of the score jump is
   the codebase, not me. A fair trajectory needs same-difficulty targets.
2. **I still missed ~15 of 19**, including 5 Highs. Catching the arithmetic one
   is progress; I am not catching double-counting (H-01), liquidation-logic
   (H-02/H-07), or the frontrun/self-liquidation classes (H-04/H-10).

## New calibration lesson (the opposite of rounds 1–2)
Rounds 1–2 said "stop over-claiming narrative Highs." Round 3 shows the reverse
failure: **I hedged H-05 and under-rated H-09 despite the evidence being IN the
code I read.** KerosineVault provably has no `oracle()` function — that's a
verifiable fact from the source, not a guess. When the disqualifying/confirming
fact is present in code you've already read, **claim it at full severity.**
Discipline means "no claims without evidence," not "hedge claims that have
evidence." I left two Highs on the table by being over-cautious.

## Method refinements (applying)
- **Claim-what-you-can-verify rule:** if the fact that makes a finding true is
  present in the read source (a missing function, a unit, an unchecked range),
  assert it at full severity with the line as proof. Reserve hedging for facts
  that genuinely require unread code.
- Keep the unit-audit-first pass — it earned its first confident High.
- Next targets: pick **similar-difficulty** contests to separate method-gain
  from target-richness, and start drilling the classes still missed
  (double-counting across accounting sets, liquidation-incentive math).

## Standing after three rounds
Genuine, measurable improvement in the previously-missed arithmetic/range class,
with an honest confound (buggier target) and a corrected calibration (stop
hedging verifiable findings). Trending toward competitive; not there yet, but the
curve is real and the weaknesses are now specific and named.
