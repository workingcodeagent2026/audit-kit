# The training loop — protocol

A repeatable cycle over finished audit contests. Each pass sharpens two
persistent artifacts: `knowledge-base.md` (vuln-class patterns) and
`METHODOLOGY.md` (process). Honest note on "training": this does **not** update
model weights. It builds a corpus that future audits load as context — a
playbook, not a fine-tune. The gain is real but lives in these files + memory.

## Why blind-then-grade (not just reading solutions)
Reading a solved contest teaches you the answer. Predicting *before* seeing the
answer, then grading, measures and improves *your process* — it surfaces what
you systematically miss. Never read the findings before writing predictions.

## The loop body (one contest per pass)

1. **Select** — pick from `curriculum.md`. Vary difficulty deliberately (a
   4-finding contest and a 19-finding one teach different things; same-size
   back-to-back controls for the "buggier target" confound).
2. **Scope & cover** — list every in-scope `.sol`; read them all before writing
   anything (the BakerFi coverage-gate lesson). Small-scope contests first.
3. **Blind predict** — run the methodology (unit-audit pass FIRST), write
   `research-<name>-predictions.md`: ranked hypotheses, each tied to a line.
   Claim-what-you-can-verify; hedge only facts needing unread code.
4. **Grade** — fetch the official report, write `research-<name>-grading.md`:
   hit / partial / miss per hypothesis, honest confounds, misses named.
5. **Extract** — for every real finding (hit OR miss), add/update a
   `knowledge-base.md` entry: the class, the detection heuristic, the example.
   A miss is the highest-value input — it's a hole in the playbook.
6. **Refine** — if a miss reveals a process gap, update `METHODOLOGY.md`.
7. **Record** — append the pass to `scorecard.md` (the trajectory).

## Running it
- **Manually / in-session:** drive one pass at a time; each is token-heavy
  (fetch scope, read N files, analyze, fetch report). One contest ≈ one focused
  session. Checkpoint by committing after every pass.
- **Automated (`/loop`):** possible, but only with a checkpoint each round and
  cost awareness — deep analysis over many files is expensive. Prefer a bounded
  batch (e.g. "3 contests then stop and review") over an open-ended loop.
- **Don't** turn this into an unbounded goal-hook; open-ended "get better at
  auditing" has no terminal state and will spin. Bound every batch.

## Success metric
Not raw hit count (confounded by target bugginess). Track: (a) hits on
same-difficulty contests over time, (b) shrinkage of a named miss-class once its
knowledge-base entry exists, (c) calibration — do my confident Highs land?
