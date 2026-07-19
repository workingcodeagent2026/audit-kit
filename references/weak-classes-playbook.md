# Weak-class detection playbook (researched, cited)

Our three still-missed classes, with mechanical heuristics + real findings.
Master source: **dacian.me/defi-liquidation-vulnerabilities** (~38 liquidation
classes) — ingest in full. Each maps onto a DYAD finding we missed.

## Class 1 — Liquidation-incentive / bad-debt math (DYAD H-02/H-07/M-01/M-02/M-05)
Heuristics:
1. **Below-1:1 incentive:** at CR ≤ 100%, does `assetsReceived < debtBurned` with
   no bad-debt socialization? → liquidators never act → permanent bad debt (M-02).
2. **Enumerate every collateral bucket; confirm each is SEIZED.** Health check
   counts asset X but liquidation only moves Y → liquidator overpays (H-09/#128).
3. **Whale case — partial liquidation supported?** If `liquidate()` burns the
   entire debt (no close-factor/repayAmount), large positions are unclearable (H-02).
4. **Redo the bonus formula by hand for edges:** unsigned `collateral -
   requirement` with no `collateral > requirement` guard; reward scaled by the
   DEBT-token decimals not the COLLATERAL-token decimals (C4 SIZE); exponential vs
   linear bonus (Wagmi Leverage V2).
5. **Dust/min-position test** enforced in EVERY position-shrinking fn (M-05).
6. **Exogenous-collateral floor:** liquidation/mint requires non-native collateral
   ≥ debt; positions backed only by the protocol's own token escape liq (H-07).
7. **Bad-debt/fee priority:** fixed % bonus reverts once CR < 100%+bonus.

## Class 2 — Double-counting across accounting sets (DYAD H-01)
Heuristics:
1. **Map every list an asset can join; find one licensed to TWO.** DYAD H-01: a
   WETH vault licensable to both KeroseneManager AND VaultLicenser → counted via
   `add()` and `addKerosene()`, summed twice in CR.
2. **In the TVL/CR aggregation loop, ask "can one address appear in >1 iterated
   collection?"** No shared dedup between the two lists = the bug.
3. **Wrapped/derivative double-count:** base locked AND its LP/receipt/wrapped
   token also accepted → both summed (DefiLlama 2022, >$1B phantom TVL).
4. **Invariant test:** deposit once, register in both eligible registries, assert
   CR == single-count CR. If CR doubles, liquidation trigger is broken.
5. **Audit the ADD/LICENSE admin paths for missing mutual exclusion** — H-01 was a
   config flaw (a vault holding two licenses), not a read-path bug.

## Class 3 — Flash-loan-protection bypass (DYAD H-03/H-04/H-10)
Heuristics:
1. **Find the guard's state-write; ask "what else writes it, can it be free?"**
   H-04: `idToBlockOfLastDeposit` set by ANY deposit incl. a fake vault → zero-cost
   trip. Guard must be set only by value-bearing, validated actions.
2. **Check the guard's access predicate:** `isValidDNft` (anyone) vs
   `isDNftOwner`. H-03: third party pushes zero-value deposits into your position
   to block your withdrawal.
3. **Fake/unvalidated-token path:** mint a worthless token, deposit to flip the
   flag. Validate the token BEFORE the guard write.
4. **Self-liquidation:** can `msg.sender` liquidate themselves? Flash loan +
   oracle move + self-liquidate = profit/bypass (H-10; Spearbit Euler EVK;
   Init Capital 1-wei self-liq blocks real liq; Aloe partial self-liq resets cooldown).
5. **Zero-value/no-op circumvention:** for any "happened this block" flag, test
   the trivial input (0 amount, dust, same-block repeat).

## Sources
- dacian.me/defi-liquidation-vulnerabilities (master taxonomy) · cyfrin.io/blog/defi-liquidation-vulnerabilities
- code4rena.com/reports/2024-04-dyad · code-423n4/2024-04-dyad-findings issues #1133, #128
- lampros.tech/blogs/multi-chain-tvl-problem · solodit.cyfrin.io
