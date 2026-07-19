# Abracadabra — BLIND predictions (COVERAGE-STRESS test)

Target: 2024-03-abracadabra-money (CDP cauldrons + MagicLP AMM + LP oracle +
staking, 29 in-scope files). Testing the coverage-first protocol.

## COVERAGE DECLARATION (honest, per the remedy)
- **Mapped all 29 files** (one-liner each — see the coverage map).
- **Deep-read (money-entry): MagicLpAggregator (oracle), CauldronV4.liquidate,
  MagicLP (sellBase/sellQuote/flashLoan).** ~4 of 29.
- **UNCOVERED (declared): LockingMultiRewards (staking rewards — likely
  findings), DegenBox (vault), Router, PMMPricing/Math internals, Factory, all
  Blast files, mixins.** I EXPECT to miss findings there. This is scoped-to-the-
  value-boundary coverage, declared — not a silent partial audit.

## Hypotheses (money-entry files, claim-what-you-verify)

**AB1 (High) — LP oracle prices with SPOT reserves → manipulable.**
`MagicLpAggregator.latestAnswer` = `min(basePrice,quotePrice) *
(baseReserve+quoteReserve)/totalSupply`, using `pair.getReserves()` (spot). An
attacker swaps/flash-loans to imbalance the pool, changing the normalized reserve
sum → inflated LP value → borrow against inflated LP collateral in CauldronV4
(whose `updateExchangeRate` reads this oracle). Manipulable-derived-value /
LP-oracle (fair-reserves not used). CLAIM.

**AB2 (High, strong lead — verify) — `_getReserves()` missing its return.**
As read: `function _getReserves() internal view virtual returns (uint256,uint256)
{ (uint256 baseReserve, uint256 quoteReserve) = pair.getReserves(); }` — no
`return`. → returns (0,0) → `latestAnswer` = 0 → LP collateral valued at zero
(DoS: no borrow / instant liquidation). Caveat: `virtual` — confirm no override.
Flag at High, pending override check.

**AB3 (High) — MagicLP `flashLoan` solvency check uses `&&` not `||`.**
`if (baseBalance < _BASE_RESERVE_ && quoteBalance < _QUOTE_RESERVE_) revert
ErrFlashLoanFailed();` — passes if only ONE token is restored, so an attacker
repays base and drains ALL quote (or vice-versa) for free. Should be `||`.
CLAIM (read the line).

## Note
Coverage-first executed: mapped all, read the value boundary, DECLARED the
uncovered surface. 2 confident Highs + 1 verify-lead from ~4 files. Grading will
show both my money-entry hit-rate AND what I forfeited in the declared-uncovered
files (the honest cost of scoping).
