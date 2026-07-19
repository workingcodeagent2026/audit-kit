# BakerFi research — GRADING (predictions vs. official findings)

Honest scoring of the blind predictions against the Code4rena report
(4 High, 8 Medium). No grading on a curve.

## Official findings
**Highs:** (1) ETHOracle returns 8-decimal Chainlink price treated as 18-decimal;
(2) Vault first-depositor inflation; (3) harvest leaves collateral locked
(hardcoded pool fee); (4) swaps lack slippage protection (`amountOutMinimum = 0`).
**Mediums (oracle/share-relevant):** min/maxAnswer circuit-breaker not checked;
Vault DoS via `totalSupply == 0` donation → `toBase()` returns 0 shares; several
fee/rounding/flashloan-fee accounting bugs; Balancer callback data unvalidated.

## Scorecard

| My hypothesis | Result |
|---|---|
| H1 Pyth confidence / `getPriceUnsafe` | **Miss.** Not a judged finding. Plausible, but not what was there. |
| H2 L2 sequencer-uptime check missing | **Miss.** Not judged. I pattern-matched to a famous class that wasn't present. |
| H3 wstETH-vs-stETH feed | **Miss** (I flagged it conditional). |
| H4 Pyth `int64→uint64` no positivity check | **Miss.** |
| H5 `getLatestPrice` staleness | **Partial/adjacent.** Real finding was min/maxAnswer (M), same "oracle robustness" theme, wrong specific. |
| H6 Pyth expo underflow | **Miss.** |
| H7 first-depositor inflation (flagged, not claimed) | **Right area, not claimed.** This was High #2 and the related M (DoS via donation). I pointed at it but did not verify — so no credit as a finding, partial credit for aim. |

## The finding I should be embarrassed about
**High #1 was the ETHOracle decimal mismatch — and it is literally our trap #2
(fake units).** Chainlink USD feeds return 8 decimals; `_PRECISION` is 18; the
code returns `answer` with no scaling. I had `EthOracle.sol` open, noted the
copy-paste `cbETH/ETH` comment, and *still missed the decimals* because I was
hunting staleness and sequencer bugs — the patterns I expected — instead of
reading what was in front of me. That is the exact failure this whole project
was built to fight: trusting a familiar narrative over ground truth.

## Honest score
Of 12 findings: **~1 area correctly aimed at (not claimed), 1 thematically
adjacent, 0 confident hits that matched.** My two confident Highs were both
wrong. My best real contribution (first-depositor) I declined to assert for lack
of code — correct discipline, zero points.

This is a realistic first-contest result and it matches the expectation set
earlier: $0–$500 while calibrating against professional wardens. It is not a
failure of the experiment — it is the experiment working. A portfolio of solved
DVD challenges said "ready"; a blind real contest said "not yet."

## What the model actually taught us (the point of "testing the models")
1. **Subsystem instinct is good, specific-bug precision is not yet.** The
   methodology correctly sent me to the oracles and the vault share math — where
   3 of 4 Highs lived. It did not convert "right area" into "right bug."
2. **I chase famous patterns over present facts.** Sequencer/Pyth-confidence are
   greatest-hits; I predicted them because they're *memorable*, not because the
   code showed them. The decimal bug was unglamorous and real, and I skated past
   it. Fix: for every oracle, mechanically verify decimals, then bounds, then
   staleness — a checklist, not vibes.
3. **Reading > fetching.** I only fetched 4 of 32 files. 3 Highs and most
   Mediums lived in `StrategyLeverage.sol`, `RebaseLibrary`, and the flash-loan
   adapter I never opened. Coverage is a prerequisite; you cannot find a bug in
   code you did not read.

## Concrete method fixes (added to METHODOLOGY next)
- Oracle checklist, mechanical: decimals normalization → min/max bounds →
  staleness → sequencer (L2) → confidence (Pyth) → positivity. Tick every box
  per feed; do not free-associate.
- Coverage gate: enumerate all in-scope files; no finding write-up until every
  value-moving file has been opened at least once.
- Kill "famous-pattern bias": before submitting a pattern-matched finding,
  require a concrete line in *this* code, not a memory of another contest.
