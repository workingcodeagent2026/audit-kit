# Audit methodology — the economic-truth lens

Most wardens hunt the classic bug list (reentrancy, access control, overflow,
uninitialized proxies). Those are well-covered by tooling and the top 50
competitors. **Our edge is the layer tools miss: economic logic that is
type-safe and reentrancy-safe but still wrong** — the on-chain equivalent of
the nine traps we caught in production. Lead with this; sweep the classics second.

## The nine-trap → vulnerability-class map

Each trap we hit live corresponds to a real, high-value audit finding class.
Read target code asking these questions first:

| Our trap | Audit question to ask the code |
|---|---|
| Fake rewards | Does a "preview"/"quote"/`callReward`-style view return a value the state-changing path is not *guaranteed* to deliver? Can preview and execution diverge (stale cache, different rounding, fee taken between)? |
| Fake units | Are two values with different decimals/units ever compared or added directly? Token amount vs share amount vs USD vs price? Missing `* 10**decimals` normalization. |
| Fake solvency | Does the code trust an oracle price without a sanity band vs a second source? What happens on depeg — is a position treated as solvent when spot says otherwise? Bad-debt socialization path. |
| Fake exits | Does it assume seized/received collateral is sellable at oracle price? Any logic that marks value using a price the market can't honor (thin liquidity, no slippage accounting)? |
| Fake availability / race | Are there ordering assumptions? Can a frontrunner change state between a user's read and their write? Sandwich on deposits/withdrawals, first-depositor share inflation. |
| Wrong-token payout | Does a function assume a specific token but accept an address param? Fee-on-transfer / rebasing / non-standard ERC20 handling. Does it check the token it received matches expectations? |
| Volume-less liquidity | TWAP/oracle sourced from a pool that can be manipulated because it's shallow? Single-block price reliance. |
| Silence signal | If a code path looks profitable but obviously nobody exploits it — why? Usually a hidden guard OR a hidden reason it doesn't actually pay. Trace both. |
| Subsidized sweeper | Are protocol-privileged actors assumed to act? What breaks if the keeper/liquidator/updater never runs, runs late, or runs adversarially? |

## Pass order (per contest)

1. **Scope & context (30 min):** read the README/docs, draw the money flow —
   who deposits what, who can withdraw what, where value enters and leaves.
   Note every external call and every price/oracle read.
2. **Economic-truth pass (our edge):** run the table above against every
   value-moving function. This is where uncontested Highs live.
3. **Accounting invariants:** for each state var tracking value, ask "can this
   drift from reality?" Rounding direction (always favor the protocol?), share
   inflation, fee math, precision loss on small amounts.
4. **Access & lifecycle:** init/upgrade, privileged funcs, pause, emergency.
5. **Classic sweep:** reentrancy (CEI), unchecked returns, arithmetic edges.
6. **Write findings as you go** — never batch at the end; you lose the repro.

## Mechanical checklists (added after the BakerFi research — see research-bakerfi-grading.md)

Blind-testing this methodology on a real finished contest exposed a failure:
it sent me to the right subsystems (oracles, vault shares) but I chased
*memorable* bug patterns (L2 sequencer, Pyth confidence) and skated past the
actual High — an 8-decimal Chainlink price used as 18-decimal (our own trap #2,
fake units). Fix: for these high-frequency areas, run a checklist, not vibes.

**Per oracle / price feed — tick every box, in order:**
1. **Decimals.** What decimals does the feed return (Chainlink USD = 8, ETH = 18,
   Pyth = expo)? Is it normalized to the protocol's precision? A missing
   `* 10**(target-feed)` is a silent, high-severity mispricing.
2. **Bounds.** Are `minAnswer`/`maxAnswer` circuit-breaker limits checked? A feed
   pinned at its floor during a crash reads as a valid price.
3. **Staleness.** Is `updatedAt` age-checked on the path actually used (not just
   in a `getSafe*` variant nobody calls)?
4. **Sequencer (L2 only).** Chainlink L2 Sequencer Uptime Feed checked?
5. **Confidence (Pyth).** Is `price.conf` used / bounded?
6. **Sign & cast.** `answer > 0` before casting signed→unsigned?

**Coverage gate:** enumerate every in-scope file first. Do not write up a
finding until every value-moving file has been opened. (In BakerFi I fetched 4
of 32 and missed 3 Highs living in files I never read.)

**Famous-pattern bias killer:** before submitting a pattern-matched finding,
point to a concrete line in *this* code. A memory of another contest is not
evidence.

## Unit audit — the #1 High in BOTH blind tests (do this first, hardest)

Across two blind contests the top-severity finding was a **unit/semantic
mismatch** (trap #2 generalized): BakerFi used an 8-decimal price as 18-decimal;
Canto passed a block number where a timestamp was expected. Both times the line
was read and the bug missed while chasing narrative bugs. So:

- For **every quantity**, name its unit: decimals? wei vs. token? per-share vs.
  absolute? **block number vs. timestamp?** basis points vs. ratio? Then check
  every place it is used/compared/passed expects that same unit.
- For **every cross-contract call argument**, verify the callee's expected unit
  (read the interface/NatSpec) — do not assume it matches yours.
- **Trace every loop's index arithmetic on paper** (Canto H-02 was
  `i + BLOCK_EPOCH` where `epoch + BLOCK_EPOCH` was intended).

**Confidence calibration (learned across three blind rounds):**
- Rounds 1–2: narrative "Highs" (governance DoS, funding/solvency, access
  control) were 0-for-4; unit/precision/loop-arithmetic were the real Highs.
  Audit the boring arithmetic first and hardest.
- Round 3: the unit-audit-first pass landed its first confident High (a
  `tvl - totalSupply` underflow). But I *hedged* two other real Highs whose
  proof was already in the code I'd read (a vault provably missing an `oracle()`
  function). **Claim-what-you-can-verify:** if the fact that makes a finding
  true is present in the read source — a missing function, a wrong unit, an
  unchecked range — assert it at full severity with the line as proof. Hedging
  is only for facts that genuinely require code you haven't read. Discipline
  means "no claim without evidence," not "hedge claims that have evidence."

## What NOT to do
- Don't submit unverified "plausible" findings — the reports version of the
  wbCOIN trap. Every finding needs a concrete path: inputs → wrong state.
- Don't pad with Lows/Infos hoping for scraps; judges down-weight noise.
- Don't compete on the $100k+ marquee contests first (200 pro wardens). Enter
  the $20k–$50k pools — fewer competitors, same skill payout.
