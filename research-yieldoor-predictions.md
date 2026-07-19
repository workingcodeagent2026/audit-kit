# Yieldoor (SHERLOCK) — BLIND predictions — platform-generalization test

Target: sherlock-audit/2025-02-yieldoor (leverage vaults + lending + oracle, 14
files). FIRST non-Code4rena contest — tests whether the method generalizes across
platforms. Consolidated method active.

## COVERAGE (declared)
- Mapped 14 files. Deep-read: **PriceFeed (oracle SOURCE, full), Leverager
  liquidatePosition + value math.** Money-entry first.
- Uncovered (declared): Vault, LendingPool, Strategy, yToken, openLeveragedPosition
  full, Uni-V3 libraries. Expect misses there.

## Hypotheses (units/oracle — our strong classes; claim-what-you-verify)

**Y1 (High) — `liquidatePosition` divides by `.decimals()` not `10**decimals`.**
`borrowedValue = owedAmount * bPrice / ERC20(up.denomination).decimals();`
`.decimals()` returns the COUNT (6 or 18), not the scaling factor `10**6`/`10**18`.
`borrowedValue` is off by ~1e5–1e17 → the solvency comparison
`if (totalValueUSD > borrowedValue)` and the entire liquidation valuation/fee are
broken. Units playbook: wrong scaling factor at the source. CLAIM (on the line).

**Y2 (High) — PriceFeed ignores staleness.** `_getChainlinkPrice` reads
`latestRoundData()` but `updatedAt` is COMMENTED OUT and the stored
`heartbeat`/`timeInterval` is never checked → stale/frozen Chainlink prices
accepted. Oracle checklist box "staleness" = NO. CLAIM (updatedAt literally
commented out in the read code).

**Y3 (Medium/High) — PriceFeed returns raw `answer`, no decimal normalization.**
`return uint256(answer);` — Chainlink feeds differ in decimals (8 vs 18). Cross-
asset comparisons (denomination price vs LP token value) mis-scale. Compounds Y1.
CLAIM (units, on the line).

**Y4 (Medium) — PriceFeed: no min/max bounds, no L2 sequencer check.** Oracle
checklist boxes unticked. CLAIM lower-priority.

## Note
Oracle checklist run as WRITTEN BOXES (Revert Lend lesson) lit up 4 boxes on a
tiny PriceFeed. Y1 (decimals-count-vs-scaling) is the confident headline High.
Testing method generalization to Sherlock's format/rules.
