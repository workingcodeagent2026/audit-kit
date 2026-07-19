# [High] Spot-balance oracle in `_computeOraclePrice` lets an attacker crash the token price and drain the pool

*Warm-up audit — target: Damn Vulnerable DeFi v4 `PuppetPool.sol`. Findings
verifiable against the challenge's public solution. Maps to our trap #7
(volume-less / manipulable liquidity feeding a spot oracle).*

## Summary
`PuppetPool` prices collateral from the **instantaneous balances** of a single
Uniswap pair. An attacker who first sells tokens into that pair collapses the
reported price, reducing the ETH collateral `borrow()` requires to near zero,
and borrows the pool's entire token balance for a fraction of its value.

## Finding description
`_computeOraclePrice()` (`PuppetPool.sol:59-62`) reads the price directly from
current reserves:

```solidity
return uniswapPair.balance * (10 ** 18) / token.balanceOf(uniswapPair);
```

This is a spot price, not a manipulation-resistant one (no TWAP, no second
source, no liquidity-depth floor). `calculateDepositRequired` (`:55-57`) scales
the required ETH linearly by this price, and `borrow` (`:30-53`) enforces only
`msg.value >= depositRequired`. Because the same pair the attacker can trade
against *is* the price source, the attacker controls the denominator of the
collateral check.

This is the on-chain form of the trap we caught in production: a value derived
from a shallow pool's state is not a value the market will honor. The code
trusts the pool's spot reading as ground truth.

## Impact
**High — total loss of the pool's token reserves.** Any actor with modest token
holdings can borrow 100% of the pool for far below collateral value in a single
transaction. Direct, permissionless theft of funds.

## Proof of concept
Challenge initial state: Uniswap pair = 10 ETH / 10 DVT; pool holds 100,000
DVT; attacker holds 1,000 DVT and 25 ETH.

1. Attacker sells 1,000 DVT into the pair. Constant-product moves reserves to
   ≈ 0.0993 ETH / 1,010 DVT (attacker also receives ≈ 9.9 ETH from the swap).
2. `_computeOraclePrice()` now returns `0.0993e18 * 1e18 / 1010e18 ≈ 9.83e13`
   wei/token — down ~10,000× from the original `1e18`.
3. `calculateDepositRequired(100_000e18) = 100_000e18 * 9.83e13 * 2 / 1e18
   ≈ 19.7 ETH`.
4. Attacker calls `borrow(100_000e18, attacker)` with ~19.7 ETH (well within
   the ~34 ETH they now hold), receiving all 100,000 DVT. Pool drained.

## Recommended mitigation
Do not price from spot pair balances. Use a time-weighted average price
(Uniswap TWAP over a meaningful window) or an independent oracle (e.g.
Chainlink) with a staleness check, and reject prices when pair liquidity is
below a configured floor. Optionally require the price used to be consistent
across two sources within a tolerance band.
