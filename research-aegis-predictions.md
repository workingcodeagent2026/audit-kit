# Aegis (SHERLOCK) — BLIND predictions — PLATFORM-AWARE drill

Target: 2025-04-aegis-op-grant (YUSD stablecoin, 5 files). Demonstrating
platform-aware pre-filtering (Sherlock rules + README hierarchy-of-truth).

## Platform pre-filter (applied BEFORE predicting)
README says: **admin trusted to set any values** → DROP all admin-config findings.
**Weird tokens (fee-on-transfer, non-standard decimals) explicitly excluded** →
DROP those. Sherlock auto-invalid → DROP staleness/sequencer. **Key invariant:
"total underlying assets ≥ total issued tokens (liabilities)."** → ATTACK THIS.

## Units-audit result (SOURCE rule) — CLEARED the mint path (no false positive)
`_calculateMinYUSDAmount`: `collateralAmount * 10**(18-collatDec) * chainlinkPrice
/ 10**feedDec` → correct 18-dec USD, `min` with order amount. Decimals correct.
Staleness IS checked here (`updatedAt >= block.timestamp - heartbeat`). I do NOT
flag the mint path — clearing it is the right call.

## Hypotheses (invariant + redeem/oracle side; leads per exploit-trace discipline)

**AE1 (lead) — `_getAssetYUSDPriceOracle` decimal mix.** `(assetUSDPrice *
10**yusdDecimals) / yusdUSDPrice` uses `assetUSDPrice` RAW (feedDecimals, 8) — not
normalized — mixed with yusd decimals. If consumed in redeem collateral sizing,
the asset-in-YUSD price mis-scales → wrong collateral out → invariant (assets ≥
liabilities) break. Lead: need the redeem consumer of this value (requestRedeem
not fully read).

**AE2 (lead) — mint/redeem peg asymmetry.** mint bounds YUSD by collateral/USD
(assumes 1 YUSD = $1), ignoring AegisOracle's YUSD market price; if redeem uses
the YUSD oracle price, arb (mint at peg / redeem at market on depeg) could break
assets ≥ liabilities. Lead.

## COVERAGE DECLARATION
Read: AegisMinting mint + price math (full). UNCOVERED (declared): requestRedeem
full, AegisRewards, AegisOracle, AegisConfig, custody/delta-neutral transfer path.
Expect misses there.

## The point of this pass
Demonstrate platform-aware calibration: I DROPPED staleness/admin/weird-token
findings up front (all would be invalid on Sherlock), CLEARED the mint decimals
(no false positive), and aimed at the README's stated invariant. Whether AE1/AE2
land, the process is the deliverable — auditing the judging rules, not just code.
