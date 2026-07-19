# Consolidated: where we went wrong (11 blind contests)

The distilled retrospective. Every failure mode we hit, ranked, with the fix.
Read THIS first — it's the compressed methodology.

## The failure modes, ranked by impact

### 1. COVERAGE — the greatest weakness (drove every zero-hit round)
Two levels, both real:
- **File-level:** Ondo 0/5 (read the token, not the mint manager); Revert Lend
  0/33; BakerFi 3 Highs in unread files.
- **Function-level (Abracadabra):** "read the file" ≠ read it — H-01/H-02 sat in
  MagicLP functions I skipped while reading swap only.
**Fix:** coverage map BEFORE predicting — enumerate every in-scope file AND every
value/price-mutating function in the money-entry files. Read in money-entry order
(deposit/mint/redeem/withdraw/liquidate/swap → their math → config). Match scope
to budget and DECLARE what's uncovered. Track coverage %.

### 2. UNITS AT THEIR SOURCE — was the #1 miss (0-for-4), now catchable (🔶)
Top-severity in BakerFi/Canto/Revert Lend/Basin, missed by clearing math that
USES a unit without reading the function that PRODUCES it.
**Fix:** the units-precision playbook (7 patterns) + the SOURCE rule (open the
decoder/config/`decimals()`). Proven: caught Size H-04 (6-dec debt vs 18-dec
collateral, 1e12x) blind.

### 3. READ-BUT-MISSED / STOPPING-AT-FIRST-BUG
Even at full coverage I missed read-code bugs: Canto block-vs-timestamp; Size H-03
(TWO lines from the H-04 I caught — I stopped at the first bug); AI Arena H-06
(second bug, same signature as H-04).
**Fix:** neighbor-sweep — when one line/param is buggy, audit every adjacent line
and every other parameter (incl. type width) before moving on. One function can
hold two Highs.

### 4. CALIBRATION SWINGS (chronic, both directions)
- Over-claimed narrative Highs (rounds 1–2, 0-for-4 on confident Highs).
- Over-hedged VERIFIABLE Highs (DYAD — hedged H-05 whose proof I'd read).
- Over-claimed an unverified LOGIC High (Abracadabra AB3 false positive).
**Fix:** claim-what-you-verify — assert at full severity ONLY what the read code
proves. For missing-code/units bugs the fact is on the line → claim. For LOGIC
bugs (`&&` should be `||`), the "proof" must be a TRACED exploit, not plausibility
→ else it's a lead.

### 5. CHECKLISTS RUN AS VIBES
Revert Lend: declared a robust-LOOKING oracle "cleared" — it had 4+ findings incl.
the sequencer check on my own list.
**Fix:** run every checklist as a written yes/no table, one row per item per feed.
"Looks careful" is not an answer to any box.

## The one-paragraph method
Map all files + value functions and DECLARE coverage. Read money-entry first, to
the function level. Run the unit-audit FIRST, tracing every unit to its source
function. Assert only what the code proves (trace exploits for logic bugs;
neighbor-sweep every buggy line). Run oracle/unit checklists as written boxes.
Everything else is intermittently caught; these five are where we systematically
bled.

## Platform rules are part of the target (Sherlock lesson)
The method generalizes across platforms (Yieldoor/Sherlock: my headline units
prediction Y1 = a confirmed finding). BUT judging rules differ: Sherlock's
**admin-trust** rules invalidate findings that assume trusted-admin
misconfiguration — my oracle-staleness/bounds Highs (valid on C4) were NOT
rewarded because the PriceFeed is owner-configured. Before each contest, read the
platform's severity/validity rules (admin-trust, "will/would", external-condition
requirements) and down-weight findings those rules exclude.

## The trajectory (honest)
11 contests. Clean Highs on loop (1/1) and size (the units class, first time).
Zero-hits all coverage-driven. The arc: units blind spot → researched → caught;
coverage → diagnosed → declared-scoping makes misses predictable → recursion to
function level found. Remaining frontier: function-level coverage + neighbor-sweep.
