# Ondo Finance (rOUSG) — BLIND predictions

Batch pass B. Target: 2024-03-ondo-finance (rebasing RWA stablecoin, 1H/4M).
Read rOUSG conversion (getShares/getROUSG, wrap/unwrap/_transfer) + traced
getOUSGPrice to PricerWithOracle (SOURCE rule). Units playbook active.

## Unit-audit (mechanical, SOURCE rule applied)
- Shares↔OUSG is a FIXED ×10_000 (price-independent); amount↔shares uses live
  price. Round-trip traced: wrap(OUSG)→OUSG×10000 shares; unwrap→shares/10000
  OUSG — reconciles. No unit inconsistency in the core conversion.
- SOURCE: `getOUSGPrice → rwaOracle.getPriceData()`. PricerWithOracle enforces
  `OPS_MAX_CHANGE_DIFF_BPS=20` (0.2%/update) and `maxTimestampDiff=30 days`
  staleness. Did NOT confirm the external oracle's DECIMALS (IRWAOracleSetter) —
  if it's not 1e18, every conversion misprices → flagged O2.

## Hypotheses

**O1 (Medium) — `unwrap` precision loss burns remainder shares without OUSG.**
`_burnShares(ousgSharesAmount)` burns ALL shares, but returns
`ousgSharesAmount / OUSG_TO_ROUSG_SHARES_MULTIPLIER` OUSG (rounds down). A
non-multiple-of-10000 `ousgSharesAmount` burns up to 9999 shares with no OUSG
returned → user loses dust, protocol gains. Round-down-favoring-protocol (units
playbook #7 / round-to-zero). Concrete.

**O2 (Medium, lead) — oracle price decimals unverified at source.** If
`rwaOracle.getPriceData()` returns non-1e18 decimals, all rOUSG↔OUSG↔$ math is
off by the decimal delta. SOURCE-rule flag; external oracle not read.

## Honest note
Hard target (1H/4M); I did NOT confidently locate the High — the core rebase math
reconciles and access/rate-limit code (RWAHub, rate limiter) I did not fully
read. Recording that gap. The value of this pass: the SOURCE rule cleanly cleared
the conversion decimals (avoiding a false positive) while flagging the one
genuinely-unverified source (O2). A miss on the High is the likely outcome.
