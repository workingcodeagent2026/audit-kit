# DYAD research — BLIND predictions (before reading findings)

Target: Code4rena DYAD (2024-04), Kerosine CDP stablecoin. Core value files
read in full (VaultManagerV2, Vault.kerosine[.unbounded/.bounded/.sol],
KerosineDenominator, KerosineManager) — coverage gate met for the value path.
**Unit-audit pass ran FIRST** (the fix under test).

## Unit-audit result (the thing I'm testing)
I traced decimals through `withdraw`, `redeemDyad`, and both `assetPrice`
implementations. They reconcile: `withdraw`'s `amount * assetPrice * 1e18 /
10**oracle.decimals / 10**asset.decimals` and `redeemDyad`'s inverse are
consistent; kerosine `assetPrice` resolves to 1e8 and `getUsdValue` divides by
1e8 to yield 1e18 USD, matching DYAD's 1e18. **No decimal mismatch found here.**
But the pass DID flag a range/domain bug of the same family (a quantity assumed
non-negative): see F1.

## Ranked hypotheses (each tied to a line; narrative-Highs demoted per calibration fix)

**F1 (High) — `UnboundedKerosineVault.assetPrice()` underflows when
`dyad.totalSupply() > tvl`.** Line: `uint numerator = tvl - dyad.totalSupply();`.
In 0.8.17 this reverts on underflow. Since kerosine represents *surplus*
collateral, exactly when the system is stressed (exogenous TVL dips below DYAD
supply) this reverts — bricking every path that reads kerosine value
(`collatRatio`, `getTotalUsdValue`, `mintDyad`, `withdraw`, `liquidate`). A
domain/unit-range bug, and a DoS at the worst possible moment.

**F2 (Medium) — `KerosineDenominator.denominator()` is manipulable.** Line:
`kerosine.totalSupply() - kerosine.balanceOf(MAINNET_OWNER)`. Kerosine price is
inversely proportional to a *mutable* balance; moving kerosine in/out of the
owner address swings every position's kerosine collateral value.

**F3 (Medium) — `liquidate()` ignores kerosine collateral.** The loop iterates
only `vaults[id]` (exogenous), never `vaultsKerosene[id]`. The liquidator burns
all the DYAD debt but receives no share of the position's kerosine — under-reward
/ stranded collateral / bad-debt pressure.

**F4 (Low/Med) — `deposit()` doesn't verify the vault is added or licensed for
`id`.** Only `isValidDNft`. Depositing to an unlicensed/unadded vault credits
`id2asset` but the value is never counted (getNonKeroseneValue checks
`isLicensed`) → user funds effectively stranded.

## Leads NOT claimed (discipline)
- `withdraw`/`redeemDyad` call `_vault.oracle()`, which KerosineVaults do not
  implement — withdrawing a kerosine vault via VaultManagerV2 would revert. I'm
  unsure this path is reachable (kerosine may be managed elsewhere); flag, not claim.
- `BoundedKerosineVault.assetPrice() = unbounded * 2` looks suspicious but may be
  intended (locked kerosine valued higher); no claim without design intent.

## Success criteria (for the fix under test)
1. Did running the unit audit FIRST change my process? (Yes — it consumed the
   first pass and cleared decimals, redirecting me to range/design bugs.)
2. Do F1–F3 match real High/Medium findings? (Prior two rounds: confident Highs
   0-for-4 — watching whether calibration improved.)
