# Curves — BLIND predictions (FUNCTION-LEVEL coverage drill)

Target: 2024-01-curves (friend.tech-style bonding-curve social tokens, 5 files,
5H/10M). Testing FUNCTION-level coverage.

## COVERAGE (function-level)
- **Enumerated all 30 functions of Curves.sol.** Deep-read EVERY value-mover:
  getPrice, getFees, _buyCurvesToken, sellCurvesToken, _transferFees, _transfer,
  _addOwnedCurvesTokenSubject, transferAllCurvesTokens, withdraw, deposit,
  sellExternalCurvesToken, setExternalFeePercent.
- Reading `_transfer` PREVENTED a false positive: it DOES call
  `_addOwnedCurvesTokenSubject(to)` — my initial "missing owned-list update" guess
  was wrong. Function-level coverage earned its keep.
- **Declared uncovered:** Security.sol, FeeSplitter.sol, CurvesERC20*.sol,
  merkle/presale/whitelist paths. Expect misses there.

## Hypotheses (neighbor-swept, exploit-traced per discipline)

**CU1 (High) — CEI violation in `_transferFees`: external `.call` before
fee-redistributor finalization.** Sell path sends `sellValue` to `msg.sender`
(and `subjectFee` to attacker-controlled `curvesTokenSubject`) via `.call`
BEFORE `feeRedistributor.onBalanceChange`/`addFees`. A reentrant party re-enters
buy/sell while the holder-fee snapshot is stale → manipulate holder-fee payouts /
drain. Exact drain depends on FeeSplitter (declared-uncovered) → HIGH-LEAD (CEI
violation confirmed on the line; full exploit needs the redistributor).

**CU2 (High) — Unbounded `ownedCurvesTokenSubjects` griefing DoS.** `_transfer`
pushes each new subject to `to`'s array via `_addOwnedCurvesTokenSubject`. An
attacker buys many distinct subjects' tokens and transfers 1 of each to a victim
→ victim's array grows unboundedly → `transferAllCurvesTokens` (loops the array)
reverts on gas → permanent DoS of the victim's batch transfer. CLAIM (read the
loop + push; traced).

**CU3 (Medium) — Malicious subject bricks all sells.** In `_transferFees`, a
failed `subjectFee` `.call` to `curvesTokenSubject` reverts the whole sell
(`revert CannotSendFunds()`). A subject contract that rejects ETH makes every
sell of its token revert → holders trapped. CLAIM.

**CU4 (Medium/Low) — No refund of `msg.value` excess in `_buyCurvesToken`.**
`if (msg.value < price + totalFee) revert` but overpayment is not refunded → stuck.
CLAIM.

**CU5 (lead) — `_transfer` doesn't notify `feeRedistributor.onBalanceChange`** →
transferring dodges holder-fee accounting. Flag.
