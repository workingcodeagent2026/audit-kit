# Aegis (SHERLOCK) — GRADING — platform-aware drill

Confirmed (3, all "Sponsor Confirmed|Won't Fix"):
1. Whale griefs redeem via redeem-limit consumption (DoS).
2. Collateral stuck in minting contract / mis-accounted as profit.
3. **Insolvency: YUSD depegs over time — redemption fees disbursed in YUSD with
   NO collateral backing them** (breaks assets ≥ liabilities).

## Scorecard
| My hypothesis | Result |
|---|---|
| AE2 mint/redeem breaks "assets ≥ liabilities" (lead) | **Directional HIT → finding #3.** I targeted the exact invariant (assets ≥ liabilities) via the peg angle; the real mechanism was redemption-FEE disbursement without backing. Right invariant, lead-level, mechanism partially off. |
| AE1 `_getAssetYUSDPriceOracle` decimal mix (lead) | **Miss** — oracle decimals weren't the bug. Correctly hedged as a lead, not asserted (no false positive). |
| (mint decimals) | **Correctly CLEARED** — no mint-path finding existed. No false positive. |
| Findings #1 (redeem-limit grief), #2 (stuck collateral) | Miss — in declared-uncovered files (requestRedeem full, custody accounting). |

## The PROCESS win (the point of this drill)
Platform-aware pre-filtering worked exactly as designed:
- **Dropped staleness / admin-config / weird-token findings up front** — and NONE
  of the 3 confirmed findings were of those types. The filter discarded zero real
  findings while it would have saved me from submitting guaranteed-invalid ones on
  Sherlock. Correct filter.
- **Cleared the mint decimals** (they were right) — no false positive.
- **Aimed at the README's stated invariant** (assets ≥ liabilities) — and finding
  #3 is precisely an assets < liabilities insolvency. Right target.

## Honest read
Specific-hit: 1 directional/lead hit on the invariant finding + 2 coverage-
attributable misses. But the DRILL's goal — internalize platform-aware
calibration — succeeded cleanly: correct pre-filter, no false positives, invariant
focus landed on the right finding. Reading the judging rules + README FIRST
changed what I looked for and what I'd submit. Platform rules are now part of the
method, demonstrated end-to-end.
