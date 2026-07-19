# AI Arena — GRADING

Official: **8 High, 9 Medium** (target-rich — confound noted).

## Scorecard
| My hypothesis | Result |
|---|---|
| B1 reRoll trusts caller `fighterType` (High) | **CLEAN HIGH HIT → H-04.** Verified from read code. |
| B2 caller-controlled DNA / attribute manipulation (High) | **CLEAN HIGH HIT → H-03** (free customization in redeemMintPass). |
| B4 staked fighters transferable (Med, lead) | **HIT → H-01** (a High). Found; appropriately hedged (hadn't read transfer overrides). |
| B3 claimNRN division-by-zero DoS (Med) | **Partial → M-04** (claim DoS, but real mechanism was gas from unbounded loop, not div-by-zero). |

**2 clean High hits + 1 High found-as-lead + 1 partial.** Best hit-quality round.

## What worked
The "claim what you can verify" rule (added after DYAD) directly produced B1 and
B2 — both were provable from the source I read, so I asserted them at full
severity instead of hedging. That is exactly the calibration fix landing.

## The read-code miss that stings (and the lesson)
**H-06: `reRoll(uint8 tokenId, ...)` — `tokenId` as `uint8` means fighters with
id > 255 can never reroll.** I quoted that exact signature and flagged the
`fighterType` bug — but missed that the SAME signature has a second bug in a
different parameter (the `uint8` width). Lesson: **when one parameter is buggy,
audit every other parameter of the same function — including its type width.**
Two bugs can share one line.

## Also missed (coverage / class gaps)
- H-02 (GameItems batch transfer), H-08 (MergingPool reentrancy): files I didn't
  read — coverage.
- H-05 (min stake → zero risk on loss, full points on win): I read
  `_addResultPoints` and didn't catch the asymmetric risk/reward at tiny stakes.
- H-07 (uninitialized `numElements`): didn't trace init.

## Honest confound
17 findings = bug-dense target; some hit-rate reflects density, not pure skill.
But the two Highs were *precise and verified*, not lucky — the method produced them.
