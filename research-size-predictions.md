# Size — BLIND predictions

Batch pass C. Target: 2024-06-size (credit/lending marketplace, 4H/13M, 32
files). Applied the "start at liquidation/money-entry" rule: read Liquidate +
SelfLiquidate FIRST. Units + weak-classes (liquidation) playbooks active. Partial
coverage (32 files; AccountingLibrary/Math/RiskLibrary read partially).

## Hypotheses

**SZ1 (High) — liquidation reward mixes debt-token and collateral-token decimals.**
In `executeLiquidate`, the reward cap is
`Math.mulDivUp(debtPosition.futureValue, liquidationRewardPercent, PERCENT)` —
`futureValue` is in **debt-token units** (e.g. USDC, 6 dec). But it is `min`'d
with `assignedCollateral - debtInCollateralToken` and ADDED to
`debtInCollateralToken`, all in **collateral-token units** (e.g. ETH, 18 dec):
```
liquidatorReward = min(assignedCollateral - debtInCollateralToken,
                       mulDivUp(futureValue, rewardPct, PERCENT));   // <- 6-dec value
liquidatorProfitCollateralToken = debtInCollateralToken + liquidatorReward; // 18-dec + 6-dec
```
The cap should be on the collateral-equivalent (`debtInCollateralToken *
rewardPct`), not raw `futureValue`. Mixing 6-dec and 18-dec mis-scales the reward
by ~1e12 → either near-zero or absurd liquidator reward. Units playbook #3
(cross-decimal non-normalization). CLAIM (read the lines).

**SZ2 (Medium) — no liquidation incentive when underwater (CR < 100%).**
When `assignedCollateral <= debtInCollateralToken`,
`liquidatorProfitCollateralToken = assignedCollateral`, but the liquidator still
pays the full `futureValue` debt via `borrowAToken.transferFrom(msg.sender,...)`.
Collateral received (< debt value) < debt paid → guaranteed loss → liquidators
won't act → bad debt. Weak-classes Class-1 heuristic #1. CLAIM.

**SZ3 (lead) — `debtTokenAmountToCollateralTokenAmount` decimals (SOURCE).**
The whole reward math hinges on this conversion handling 6→18 decimals + oracle
price correctly. AccountingLibrary not fully read — flag.

## Note
Testing whether units-playbook + "start at liquidation" + claim-what-you-verify
catches the scout-flagged "6-dec debt used for 18-dec collateral reward". SZ1 is
the confident High.
