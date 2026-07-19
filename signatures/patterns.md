# Signature catalog — greppable bug patterns for cross-protocol sweeping

The insight: functions get copied across forks/protocols/chains; their bugs copy
too. Every fork made before the original's fix still carries the bug. So: encode
each confirmed bug as a signature, sweep many repos, manually verify matches.

Each signature = a regex + the class + a real confirmed example + false-positive
notes (a match is a LEAD to verify, never an auto-finding).

| # | Signature (regex) | Class | Confirmed example | FP notes |
|---|---|---|---|---|
| S1 | `/\s*[\w.()]*\.decimals\(\)` (divide by `.decimals()` directly) | units — count vs 10**dec | Yieldoor (Sherlock, confirmed) — `/ ERC20(x).decimals()` | legit only if intentionally dividing by the count (rare); almost always a bug |
| S2 | `\.getReserves\(\)` feeding a price/value/mint calc | manipulable spot oracle | Abracadabra H-04, DVD Puppet | fine if TWAP-derived or only for events |
| S3 | `balanceOf\(address\(this\)\)` used as a claim/mint amount | balance-as-amount | LoopFi H-01 (confirmed) | fine if it's a genuine delta measurement |
| S4 | `latestRoundData` with `updatedAt` commented/unused | oracle staleness | Yieldoor PriceFeed | often OUT of scope (Sherlock auto-invalid) — QA signal only |
| S5 | `<\s*\w+.*&&.*<\s*\w+` inside a flash-loan/solvency revert | logic `&&` vs `\|\|` | (Abracadabra AB3 candidate) | verify exploit path; many `&&` are correct |
| S6 | `onERC721Received` / callback before a state finalize | reentrancy / callback | Revert Lend H-02 | needs CEI trace |
| S7 | `push\(` into an array indexed by attacker-suppliable key, looped elsewhere | unbounded-array griefing | Curves H-01 (confirmed) | verify the loop is user-facing/gas-bounded |
| S8 | preview/limit fn using a DIFFERENT call than the executor | predictor-vs-executor | PoolTogether M-03, BakerFi | needs the pair compared |

## How to use
`./sweep.sh <cloned-repo-dir>` runs all signatures, prints file:line matches per
signature. Every hit is a LEAD — open it, apply the relevant playbook, verify.
The value is triage: sweep 20 repos in minutes, then hand-audit only the hits.

## Where the edge is (honest)
Most-copied templates (OZ, Uniswap core) are the most-audited — their known bugs
are found. The edge is in: RECENT forks of protocols that had RECENT bugs (forked
before the fix), less-famous templates, and cross-chain redeployments of a
protocol whose bug was patched on one chain but not another. Sweep new/obscure
forks, not blue-chips.
