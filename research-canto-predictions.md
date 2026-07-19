# Canto LendingLedger research — BLIND predictions (before reading findings)

Target: Code4rena Canto Invitational (2024-01). Single in-scope file
`LendingLedger.sol` (106 SLOC) — **entire surface read** (coverage gate met).
A MasterChef-style CANTO reward ledger for lending markets. No oracles → oracle
checklist N/A; edge here is reward accounting (our trap #1) + invariants.
Official report has 2 High + 2 Medium.

## Ranked hypotheses (each tied to a concrete line, per the anti-bias rule)

**H1 (High) — De-whitelisting a market bricks claims AND withdrawals.**
`claim` and `sync_ledger` both call `update_market`, which
`require(lendingMarketWhitelist[_market], "Market not whitelisted")`. If
governance calls `whiteListLendingMarket(market, false)`, every user of that
market can no longer `claim` earned CANTO nor `sync_ledger` a withdrawal —
rewards and accounting frozen. Concrete: `update_market` line 1 require.

**H2 (High) — No solvency link between `setRewards` and actual CANTO held.**
`setRewards` writes `cantoPerBlock[epoch]` with no escrow; `claim` pays via
`msg.sender.call{value: cantoToSend}`. Nothing guarantees the contract holds
enough CANTO. Promised rewards can exceed balance → first claimers drain, later
claimers' calls revert. Promise-vs-payout mismatch — our trap #1 exactly.

**H3 (Medium) — `claim` allows current (unfinished) epoch, contradicting its
own spec.** NatSpec: "Can only be performed for prior (i.e. finished) epochs,
not the current one." But `update_market` accrues to `block.number`, including
the current partial epoch, and `claim` has no epoch guard. Intent/impl mismatch;
lets users realize current-epoch rewards early.

**H4 (Medium) — `secRewardsPerShare` accrues unconditionally (dev TODO).**
`market.secRewardsPerShare += uint128((blockDelta * 1e18) / marketSupply); //
TODO: Scaling`. Secondary rewards accrue every block regardless of any config,
with an explicit unfinished-code marker — likely misaccounting.

**H5 (Low) — `uint128` truncation.** `accCantoPerShare`/`secRewardsPerShare`
cast reward math to `uint128`; extreme values truncate silently.

## Leads I am NOT claiming (discipline)
- `setRewards` retroactively overwriting `cantoPerBlock` for an epoch whose
  reward a lagging market hasn't accrued yet could rewrite history — but this
  needs a careful epoch/`lastRewardBlock` timing trace I haven't fully done.
  Flag, don't assert.
- No reentrancy claim: `claim` sets `rewardDebt` before the external call (CEI
  followed), so I explicitly do NOT report reentrancy.

## Success criterion
Did H1/H2 (confident Highs) match the two real Highs? And did I avoid the
BakerFi failure — reading the whole file and tying each claim to a line?
