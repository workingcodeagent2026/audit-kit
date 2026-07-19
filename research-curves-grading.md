# Curves — GRADING (function-level coverage drill — best result yet)

Official: **5 High, 10 Medium.**

## Scorecard
| My hypothesis | Result |
|---|---|
| CU2 unbounded ownedCurvesTokenSubjects griefing DoS (High) | **CLEAN HIGH HIT → H-01.** Exact (dust-transfer array inflation → presale gas DoS). |
| CU5 `_transfer` doesn't call `onBalanceChange` (lead) | **HIT → H-02** (a High — "onBalanceChange only on buy/sell, not transfers" → repeat fee claiming). Found as a flagged lead. |
| CU3 malicious fee-recipient bricks sells (Med) | **HIT → H-03** (a High — honeypot via malicious REFERRAL receiver blocks sells). Right mechanism/class; I attributed it to subjectFee not referral, and under-rated severity. |
| CU4 no msg.value refund (Med/Low) | **CLEAN HIT → M-09.** Exact, correct Medium. |
| CU1 CEI/reentrancy in `_transferFees` (High-lead) | **Partial → M-06** (reentrancy in fee claiming, judged Medium). Appropriately hedged to lead — good calibration. |

**3 Highs found (H-01 clean, H-02 as lead, H-03 under-rated) + 1 Medium (M-09) +
1 partial (M-06).** Best result of all 12 contests.

## The 2 misses — both in DECLARED-uncovered files
- H-04 (FeeSplitter.setCurves no access control) — FeeSplitter.sol, declared uncovered.
- H-05 (broken onlyOwner modifier) — Security.sol, declared uncovered.
Every miss is exactly attributable to a coverage boundary I named up front.

## What this validates (the whole consolidated method, end-to-end)
1. **Function-level coverage WORKS.** Reading every value function caught 3 Highs
   + a Medium. This is the direct fix for the Abracadabra function-level recursion.
2. **Reading `_transfer` prevented a false positive** (it DOES update the owned
   list) AND surfaced CU5 → H-02. Coverage pays both ways.
3. **Neighbor-sweep** caught multiple bugs clustered in the fee/transfer functions.
4. **Declared coverage** made the only 2 misses fully attributable (uncovered files).
5. **Exploit-trace discipline** correctly hedged CU1 to a lead (it was Medium, not
   the High I might have over-claimed pre-AB3-lesson).

## Calibration note
Under-rated H-03 (Med vs actual High) — the honeypot-blocks-sells is High impact.
Minor; the win is that the mechanism was caught. No false positives this round.

## Read
3 Highs + 1 Med on a bug-dense target, misses only in declared-uncovered files,
zero false positives. The consolidated method — function-level coverage +
money-entry order + units/SOURCE + neighbor-sweep + claim-what-you-verify +
declared scoping — executed end-to-end and produced the best pass of the project.
