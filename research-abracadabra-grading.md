# Abracadabra — GRADING (coverage-stress test)

Official: **4 High, 16 Medium.**

## Money-entry files I deep-read — scorecard
| My hypothesis | Result |
|---|---|
| AB1 LP oracle spot-reserve manipulation (High) | **CLEAN HIGH HIT → H-04** ("Oracle Price Manipulation via Flash Loans — MagicLpAggregator uses spot reserve balances"). Exact. |
| AB2 `_getReserves()` missing return (High-pending-verify) | **HIT → M-10.** Found the exact bug; it was judged MEDIUM (my verify-caveat was right — `virtual`, effectively lower impact). Over-rated severity, correct bug. |
| AB3 flashLoan `&&` vs `||` (High) | **MISS / FALSE POSITIVE.** Not a judged finding. I over-claimed a High from my own exploit-reasoning, not a confirmed path. |

Money-entry result: **1 clean High + 1 Medium hit + 1 false positive** from ~4 files.

## The DECLARED-uncovered cost (as predicted)
I explicitly declared these uncovered and predicted misses there — and forfeited:
- **H-02** (pool-init rounding), **H-03** (bootstrap imbalance, BlastOnboardingBoot)
- ~13 Mediums: Router (M-03), LockingMultiRewards staking (M-05/M-07/M-15),
  Blast files (M-01/02/08/14/16).
All in files I named as uncovered. **The misses were predictable and
attributable, not silent surprises** — this is exactly what the coverage-first
declaration is for.

## What the coverage-stress test proved
1. **Declared coverage works:** honest scoping turned "mystery 0" into "forfeited
   these named files" — diagnosable, not demoralizing.
2. **Money-entry-first caught the top oracle High (H-04).** The ordering rule delivered.
3. **BUT coverage RECURSES to the function level.** H-01 (TWAP manipulation via
   `_twapUpdate` ordering) and H-02 (init rounding) live in MagicLP —
   a file I "read," but I read `sellBase/sellQuote/flashLoan` and NOT
   `_twapUpdate`/init, which are equally value-critical. Under-coverage happened
   *inside* a money-entry file.

## New lessons (applying)
- **Coverage recurses:** in a money-entry file, enumerate and read EVERY
  value/price-mutating function (swap AND twap-update AND init AND sync), not
  just the obvious swap. Partial-file coverage = the same failure at smaller scale.
- **Verify the exploit path before a logic-bug High** (AB3 false positive):
  claim-what-you-verify is solid for missing-code/units (AB2, H-04), but for a
  LOGIC bug the "verification" must be a traced exploit, not my own plausibility
  argument. Downgrade unverified logic-Highs to leads.

## Read
On the value boundary I read: 1 clean High + 1 real bug (mis-sev) + 1 false
positive. Coverage capped the rest exactly as declared, and revealed it recurses
to function level. Best-executed coverage protocol so far; the diagnosis holds
and sharpened.
