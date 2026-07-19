# Units & Precision — detection playbook (researched, cited)

Built to close our #1 recurring weakness (units/decimals at their source — the
top-severity miss in BakerFi, Canto, Revert Lend, Basin). Synthesized from
auditor references and real Code4rena/Sherlock findings; sources at the bottom.
Load this before the unit-audit pass.

## The seven concrete bug patterns (each = detect + real example)

1. **Division before multiplication.** `a / b * c` ≠ `a * c / b`; the early
   divide truncates. Detect: scan every `/`; **expand helpers** (`wmul`, `wdiv`,
   `mulWad*`) to expose hidden divides. Real: Numoen —
   `mulDiv(amount0, 1e18, liquidity) * token0Scale` lost precision; fix scales
   first: `mulDiv(amount0 * token0Scale, 1e18, liquidity)`.

2. **Round-down-to-zero.** Small/large division yields 0, breaking proportional
   logic. Detect: small-numerator divisions feeding state changes (collateral,
   fees, rewards). Real: Cooler — `loanCollateral * repaid / loanAmount` → 0,
   reducing debt without releasing collateral. Fix: revert on 0.

3. **Missing normalization across different-decimal tokens.** Adding/comparing
   6-dec and 18-dec amounts. Detect: every multi-token arithmetic — look up each
   `decimals()`; watch for values that "disappear" (~50% off). Real: Notional —
   18-dec DAI mixed with 6-dec USDC → ~50% undervaluation.

4. **Excessive/repeated scaling.** Already-scaled value scaled again
   (`value * 1e18 * 1e18`). Detect: trace a value across module boundaries;
   count scaling steps. Notional-family.

5. **Mismatched precision between modules.** One module uses `token.decimals()`,
   another hard-codes `1e18`. Detect: grep hard-coded `1e18`/`1e27` and check vs
   dynamic decimals; **test with 6- and 8-dec tokens**. Real: Yearn — vault used
   token decimals, yield module hard-coded 1e18 → breaks non-18-dec tokens.

6. **Unsafe downcast invalidates a prior check.** `require(a>b)` then
   `uint32(a)` overflows. Detect: every narrowing cast (`uint32/uint128/...`) —
   was an invariant checked in the WIDE type before the cast? Real: Balancer —
   `endTime>startTime` checked, then downcast to uint32 wrapped. Fix: `SafeCast`.

7. **Rounding direction favors the wrong party.** Fees/outputs `mulWadDown`
   where `mulWadUp` belongs. Detect: for each fee/output, ask who benefits from
   the rounding. Real: SudoSwap — protocol fee `mulWadDown` under-collected.

## The SOURCE rule (our specific failure)
Every one of our misses cleared the math that USES a unit while never opening the
function that PRODUCES it. So, mechanically:
- **Oracle decimals overflow:** normalization `36 - feedDecimals - tokenDecimals`
  underflows/reverts (or misprices) when `feedDecimals + tokenDecimals > 36`.
  You only see this by reading the oracle wrapper AND checking the actual feed's
  `decimals()`. Real: StableOracleDai used the wrong feed's decimals.
- For every quantity, open its **origin**: the `decode*`/`getConfig`/
  `decimals()`/config-setter. An unread source is an UNCLEARED unit. (Basin H-02
  lived in `decodeWellData`, a function we never opened.)

## Mechanical unit-audit procedure (run FIRST, write it down)
1. Enumerate every value-bearing variable and its claimed unit (decimals, wad/
   ray, per-share, wei, block vs timestamp, bps).
2. For each, **open and read its source function** — decoder, config, oracle
   `decimals()`. Confirm the unit it actually produces. Tick yes/no in writing.
3. Expand every `wmul/wdiv/mulWad*` helper to raw math; flag div-before-mul.
4. For every multi-token op, list each token's decimals; confirm normalization.
5. For every narrowing cast, confirm the invariant was checked in the wide type.
6. For every fee/output, confirm rounding direction favors the protocol.
7. Test-think 6-dec and 8-dec tokens and the `>36 decimals` oracle edge.

## Tooling
- **Slither** detects division-before-multiplication (`divide-before-multiply`).
  Run it first as a cheap sweep.
- **Semgrep** (semgrep-solidity rules) for pattern variants — hard-coded 1e18,
  unsafe casts.
- **Invariant/fuzz** (Foundry) with non-18-decimal tokens surfaces normalization
  and rounding bugs static tools miss.

## Sources
- dacian.me/precision-loss-errors (patterns + the named examples above)
- zokyo-auditing-tutorials … /18-decimal-assumption
- lab.guardianaudits.com … /division-precision-loss
- audit-quality.github.io/security-checklist/oracle/ (Chainlink checks)
- Trail of Bits — Slither (blog.trailofbits.com/2018/10/19/slither…)
