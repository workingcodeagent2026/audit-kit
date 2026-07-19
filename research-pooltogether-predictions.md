# PoolTogether V5 research — BLIND predictions

Pass 4/4 in the batch. Target: 2024-03-pooltogether (PrizeVault, ERC4626 prize
savings). Core value fns read (totalAssets, _totalDebt, maxDeposit/Redeem,
liquidatableBalanceOf, transferTokensOut, _depositAndMint). Mature, heavily-
commented codebase — expect few findings; hard target. Unit-audit pass first.

## Unit-audit result
Shares are 1:1-capped to assets by design ("never mints >1 share per asset").
Decimals consistent (asset decimals mirrored). The risk surface is **rounding
direction** and **share-count vs asset-value mixing in liquidation**, not decimals.

## Hypotheses (rounding/liquidation focus, per edge)

**P1 (Medium) — `liquidatableBalanceOf` vs `transferTokensOut` fee-rounding mismatch.**
`liquidatableBalanceOf` advertises `_liquidYield = availableYield * (FEE_PRECISION
- fee)/FEE_PRECISION` (round down). `transferTokensOut` independently recomputes
`_yieldFee = amountOut*FEE_PRECISION/(FEE_PRECISION-fee) - amountOut` and reverts
if `amountOut + fee > availableYield`. The two roundings can disagree by 1 wei →
either a liquidation that `liquidatableBalanceOf` says is valid reverts, or a
hair more yield leaves than intended.

**P2 (Medium) — share-vs-asset denomination in share liquidation.**
When `_tokenOut == address(this)`, `liquidatableBalanceOf` caps at
`_twabSupplyLimit` (a share count) but compares/returns against `_liquidYield`
(asset-denominated), and `transferTokensOut` `_mint`s `_amountOut` shares. If
1 share != 1 asset (vault at a loss), the yield liquidated in shares is
mis-valued. Unit/denomination mix.

**P3 (Low) — `_asset.approve` (not forceApprove) in `_depositAndMint`.**
Plain `approve` to the yield vault; handled for USDT via reset-to-0, but
non-standard tokens could still revert. Devs partially mitigated; low.

## Leads NOT claimed
- ERC777 reentrancy in `_depositAndMint`: devs explicitly ordered transfer-before-
  mint and documented it. Not claiming without a concrete break.
- `maxRedeem` loss-path `mulDiv` rounding: looks carefully done (rounds up to
  avoid over-withdraw); flag as the next place to look, no claim.

## Note
Honest expectation: this is a mature target; I may score 0. The value of the
pass is testing whether the rounding-focus + unit-audit holds on hard code.
