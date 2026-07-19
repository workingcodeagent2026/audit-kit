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

## What NOT to do
- Don't submit unverified "plausible" findings — the reports version of the
  wbCOIN trap. Every finding needs a concrete path: inputs → wrong state.
- Don't pad with Lows/Infos hoping for scraps; judges down-weight noise.
- Don't compete on the $100k+ marquee contests first (200 pro wardens). Enter
  the $20k–$50k pools — fewer competitors, same skill payout.
