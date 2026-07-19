# Knowledge base — vulnerability-class pattern library

The compounding artifact. One entry per class: the pattern, a mechanical
detection heuristic, and real examples from graded contests. Grows every pass —
**misses are the highest-value entries** (a hole in the playbook). Load this as
context before an audit.

Legend: ✅ we've hit this class · ❌ we've missed it (priority to drill) · 🔶 partial

---

## Caller-controlled parameter trusted as truth ✅ (produced 2 confident Highs)
**Pattern:** a function accepts a parameter it should derive from state, and uses
it for limits/pricing/attributes. Or a randomness/attribute source is caller-
supplied.
**Heuristic:** for every external-fn parameter, ask "should this be read from
storage instead?" And check EVERY parameter of a buggy function — including its
**type width** (a `uint8 tokenId` silently caps at 255).
**Examples:** AI Arena H-04 (reRoll trusts `fighterType` param), H-03 (attributes
from caller DNA string), H-06 (`uint8 tokenId` — missed, same line as H-04).

## Units & semantics ❌ (our #1 recurring miss — the top High in 2/3 contests)
**Pattern:** two quantities in different units are compared/added/passed as if
identical. Decimals (8 vs 18), wei vs token, per-share vs absolute, **block
number vs timestamp**, basis points vs ratio.
**Heuristic:** name the unit of *every* value and every cross-contract argument;
confirm the callee expects the same. Do this pass FIRST.
**Examples:**
- BakerFi H-01: Chainlink 8-decimal price returned as 18-decimal (no scaling).
- Canto H-01: block number passed where gauge controller expects a timestamp.

## Range / domain underflow ✅
**Pattern:** subtraction assumes `a >= b`; in ≥0.8 it reverts, bricking the path
exactly when the invariant is stressed.
**Heuristic:** every `a - b` on protocol quantities — can `b > a` in a real
(esp. stressed) state? What breaks if it reverts?
**Example:** DYAD H-08 — `tvl - dyad.totalSupply()` reverts when undercollateralized, trapping kerosine. (We predicted this via the unit-audit pass.)

## Oracle robustness ❌/🔶
**Pattern:** price feed consumed without full validation.
**Heuristic (checklist, per feed):** decimals → min/maxAnswer bounds → staleness
on the *used* path → L2 sequencer uptime → Pyth confidence → `answer > 0`.
**Examples:** BakerFi M "min/maxAnswer not checked"; BakerFi decimals (above).
TWAP variant: window must be long relative to pool liquidity (DVD Puppet V3).

## Reward / accounting desync ✅/🔶
**Pattern:** the payout loop and the claimed/accounting update are not in
lockstep (payout per-iteration, bookkeeping committed once), or precision is
lost in per-share math.
**Heuristic:** does the money-moving step happen exactly as often as the
accounting step? Check-effects-interactions on the ledger. Scan per-share
scaling (1e18 vs 1e27) and divide-before-multiply.
**Examples:** DVD The Rewarder (duplicate claims); Canto M-01 (secReward 1e18
should be 1e27 → rounds to 0); Canto M-02 (div-before-mul precision loss).

## Liquidation incentive / bad-debt math ❌ (priority drill)
**Pattern:** liquidation reward formula, partial-liquidation support, or which
collateral buckets get moved is wrong → liquidators under-incentivized, bad debt
accrues, or collateral stranded.
**Heuristic:** trace a liquidation end-to-end: does the liquidator profit at
every CR? Are ALL collateral sets moved? Can only-full-burn block large
positions?
**Examples (we mostly MISSED these — drill them):** DYAD H-02 (no partial
liq), H-07 (missing exo check), H-09 (kerosine not moved — we hit this one),
M-01/M-02/M-05 (bonus logic, no incentive below 1:1, small positions).

## Double-counting across accounting sets ❌ (priority drill)
**Pattern:** the same asset counted in two registries/paths inflates a value
(collateral ratio, TVL, votes).
**Heuristic:** when a value sums over a set, can an element belong to two sets
(licensed in two managers, in two vault lists) and be counted twice?
**Example:** DYAD H-01 (vault licensed to both KeroseneManager and
VaultLicenser counted twice in CR). We missed it.

## Missing / wrong authorization ✅ (but stop over-weighting)
**Pattern:** privileged/costly action lacks an owner/consent check; or a check
guards identity but not legitimacy (flash-loanable votes).
**Heuristic:** every state-changing external fn — who *should* be allowed, is it
enforced? Note: these were 0-for-4 as *confident Highs* — real but over-predicted.
**Examples:** DVD Truster (arbitrary call), Selfie (flash-loan governance),
Naive Receiver (no beneficiary consent), DYAD M-07 (burnDyad missing owner check).

## Ordering / CEI at the logic OR authorization layer ✅
**Pattern:** effect/interaction happens before the precondition that should gate
it; or state read after it's mutated.
**Heuristic:** for each sensitive fn, is the check strictly before the effect?
Is any value read after a transfer/mutation?
**Examples:** DVD Climber (execute runs calls before readiness check), Free Rider
(`ownerOf` read after NFT transfer → pays buyer), Side Entrance (deposit during
flash loan).

## Manipulable derived value ✅
**Pattern:** a price/weight derived from a mutable balance or shallow pool.
**Heuristic:** is any critical number a function of a spot balance / a mutable
address balance / a low-liquidity pool?
**Examples:** DYAD M-09 (kerosine price via denominator = supply − owner
balance); DVD Puppet (spot pool oracle).

## Predictor vs. executor mismatch ❌ (drill — same family as units)
**Pattern:** a function that *predicts/limits* an action uses a different
mechanism than the function that *executes* it, so the limit is wrong.
**Heuristic:** for every max/preview/limit function, find the executor it guards
and confirm they use the SAME underlying call. `maxDeposit` via
`maxDeposit()` but deposit via `mint()`; `getPrecision()` says 18 but code
returns 8; preview via `convertToAssets` but exec via `previewRedeem`.
**Examples (missed — read the lines, didn't connect them):** PoolTogether M-03
(maxDeposit/maxDeposit() vs mint()), M-02 (convertToAssets vs previewRedeem);
BakerFi decimals (getPrecision vs raw answer).

## Flash-loan-protection bypass ❌ (drill)
**Pattern:** anti-flash-loan guard (same-block deposit flag) circumvented via
zero-value calls, fake tokens, or self-interaction.
**Heuristic:** any "same block" / "deposited this block" guard — can an attacker
set it cheaply for a victim, or route around it via self-liquidation?
**Examples (missed):** DYAD H-03 (zero-value deposit sets block → DoS), H-04
(fake vault frontrun), H-10 (self-liquidation bypass).
