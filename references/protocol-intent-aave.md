# Intent-driven auditing — worked on Aave

The principle (user's insight): understand the protocol's GOAL and promises → a
bug is any path where the code violates its own promise. Read the intent first,
then hunt for where reality diverges. This is how you know what a bug even IS.

## What Aave is / does
Aave is a decentralized, non-custodial **money market** (lending/borrowing):
- **Suppliers** deposit assets → earn interest, receive an interest-bearing
  receipt (aToken / share).
- **Borrowers** post collateral → borrow other assets against it, pay interest.
- **Overcollateralized**: you must lock MORE value than you borrow.
- **Algorithmic interest**: rate rises with utilization (more borrowed = dearer).
- **Liquidation**: if collateral value falls so health factor < 1, anyone can
  repay the debt and seize collateral at a **bonus** — this keeps the pool solvent.

## What Aave is TRYING TO ACHIEVE (the "mind")
Let people earn yield on idle assets and unlock liquidity without selling —
trustlessly, permissionlessly — while **staying solvent so suppliers can always
withdraw.** Solvency is the sacred promise.

## The core invariants = the definition of a bug
A bug is a path that breaks one of these:
1. **Solvency:** total collateral value ≥ total debt, always. (Break it = the
   bounty's "protocol insolvency" Critical.)
2. **Liquidation works & is incentivized:** every HF<1 position must be
   liquidatable, liquidation must reduce bad debt, and the bonus must make it
   worth a liquidator's while. (Weak-classes-playbook Class 1.)
3. **Honest interest:** interest accrues correctly; suppliers earn exactly what
   borrowers pay; indexes track it; **accrue before every state change** (we
   verified this holds in V4 — all 14 Hub entrypoints).
4. **Share accounting:** shares↔assets consistent; no minting shares without
   depositing; no withdrawing more than your share.
5. **Conservation:** nobody leaves with more than they put in (minus interest owed).

## V4's NEW goal (Hub-and-Spoke) → NEW invariants → NEW bug surface
V4 unifies liquidity in a shared **Hub** (the canonical ledger) while **Spokes**
implement asset-specific borrow/risk logic. Intent: capital efficiency +
modularity — one liquidity layer serving many markets, risk isolated per Spoke.
New promises to attack:
- **Hub↔Spoke trust boundary:** the Hub must enforce its GLOBAL invariants even
  as Spokes orchestrate flows. (A *legitimate* Spoke action that breaks a Hub
  invariant is in scope — a malicious Spoke is not.)
- **Premium liabilities:** the risk-premium accounting (novel — our open leads).
- **Risk-adjusted rate:** collateral risk score (0–1000%) → final rate.

## The auditor's move (intent → structure → bug)
1. State each promise as an invariant (above).
2. For each, ask: *is there ANY sequence of operations that violates it?* — a
   deposit/borrow/repay/liquidate/rate-change ordering, an edge value, a
   cross-Spoke flow.
3. Where you find a candidate violation, trace it to a concrete path + build a PoC.
This is why "understand the goal" comes first: without the invariant, you're
grepping for patterns; with it, you're hunting a specific promise to break.
Pair this with the mechanics (smart-contract-mechanics.md): intent tells you
WHAT would be a bug; mechanics tell you HOW it could happen.
