# Ondo Finance — GRADING

Official: **1 High, 4 Medium.**
- H-01: OUSGInstantManager assumes fixed 1:1 USDC=USD without checking the USDC
  oracle → excessive OUSG mint on a USDC depeg.
- M-01/02/03: BUIDL min-holding / redemption-limit integration issues.
- M-04: KYC check in `_beforeTokenTransfer` blocks the BURNER from non-KYC accounts.

## Scorecard
| My hypothesis | Result |
|---|---|
| O1 unwrap dust precision loss (Med) | **Miss** (not judged). |
| O2 oracle price assumption unverified (Med, lead) | **Directionally right, no match.** H-01 IS an oracle-price-assumption bug — but the USDC 1:1 PEG in OUSGInstantManager, not the OUSG oracle decimals I traced. Right theme, wrong feed + wrong contract. |

**0 hits.**

## Root cause: coverage (again)
All 5 findings live in **OUSGInstantManager / RWAHub** (mint/redeem, USDC peg,
BUIDL, KYC) — I read **rOUSG + PricerWithOracle** instead. On a "3-file" contest
I focused on the rebasing token and never opened the instant-mint manager where
the bugs were. The units playbook worked *where I pointed it* — it correctly
CLEARED the rOUSG rebase math (which reconciles; no false positive, good
calibration) — but I pointed it at the wrong contract.

## The refined lesson
Coverage isn't just "read every file" — it's **read the file where value ENTERS
and EXITS first** (mint/redeem/deposit/withdraw entry points), not the token
math. H-01 was at the USDC→OUSG mint boundary. My instinct (O2: "the price
assumption is the risk") was correct in theme; I traced the OUSG price oracle
instead of the USDC peg assumption at the mint entry point. **Start the unit
audit at the money-entry function, then trace its price/peg source — that would
have led to the USDC 1:1 assumption directly.**

## Honest read
0/5 by mis-targeting coverage on a small contest. The method (SOURCE rule,
no-false-positive clearing) behaved well on what it saw; the failure was WHERE I
aimed it. For the next pass (Size, the liquidation target), cover the
liquidation + mint/redeem entry points FIRST.
