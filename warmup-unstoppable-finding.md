# [Medium] Strict raw-balance invariant in `flashLoan` is permanently brickable by a 1-wei token donation

*Warm-up — Damn Vulnerable DeFi v4 `UnstoppableVault.sol`. Verifiable against
the public solution. Class: accounting state assumed equal to raw token balance
(our "can this drift from reality?" invariant pass).*

## Summary
`flashLoan` requires `convertToShares(totalSupply) == totalAssets()`, i.e. that
the vault's ERC4626 share accounting exactly equals its raw token balance. Any
external party can transfer tokens **directly** to the vault (bypassing
`deposit`), making `totalAssets()` exceed the accounted value permanently and
causing every `flashLoan` call to revert. The core function is bricked for the
cost of 1 wei of the asset.

## Finding description
`UnstoppableVault.sol:84-85`:

```solidity
uint256 balanceBefore = totalAssets();                       // asset.balanceOf(this)
if (convertToShares(totalSupply) != balanceBefore) revert InvalidBalance();
```

`totalAssets()` (`:71-73`) returns the raw ERC20 balance. `convertToShares`
derives from `totalSupply`/accounted assets. These are equal only while assets
enter exclusively through `deposit`. A direct `token.transfer(vault, 1)` raises
the raw balance without minting shares, so the equality breaks and never
self-heals. Every subsequent flash loan reverts on line 85.

## Impact
**Medium — permanent denial of service of the vault's core (flash-loan)
functionality, at negligible attacker cost and no fund loss.** Rated Medium
rather than High on two honest grounds: (1) no value is stolen — user deposits
remain withdrawable; (2) the owner *can* recover via the `whenPaused` +
`execute` delegatecall path (`:120-123`) by rebalancing accounting. It is not
High because it is recoverable by a privileged actor; it is not Low because,
absent that intervention, the protocol's advertised function is dead and the
griefing cost is ~zero.

## Proof of concept
1. Vault operating normally: `totalAssets() == convertToShares(totalSupply)`.
2. Attacker calls `token.transfer(address(vault), 1)` (no `deposit`).
3. Now `totalAssets()` is larger by 1; `convertToShares(totalSupply)` is
   unchanged. Line 85's equality fails.
4. Every `flashLoan(...)` reverts with `InvalidBalance()`. Permanent until owner
   intervention.

## Recommended mitigation
Do not assert exact equality between raw balance and share accounting — direct
transfers are always possible. Either track deposited assets in an internal
accumulator (compare against that, not `balanceOf`), or replace the strict
equality with the intended solvency check (`totalAssets() >= accounted`), which
tolerates donations instead of breaking on them.
