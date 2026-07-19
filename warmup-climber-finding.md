# [High] `execute` runs the operations before verifying they were scheduled, letting a caller self-authorize a full takeover

*Warm-up — Damn Vulnerable DeFi v4 `ClimberTimelock.sol`. Verifiable against the
public solution. Class: checks-effects-interactions violated at the authorization
layer — action executed before its own precondition is checked.*

## Summary
`execute` performs all target calls **first** (`:89-91`) and only afterward
checks the operation is `ReadyForExecution` (`:93-94`). Since `execute` is
permissionless and the timelock self-administers (`ADMIN_ROLE` granted to
`address(this)`), the executed calls can grant the attacker `PROPOSER_ROLE`, set
the delay to zero, and **schedule this very operation** — so by the time the
readiness check runs, the operation has retroactively become valid. Total
control of the timelock (and whatever it governs) in one transaction.

## Finding description
`execute` (`:71-97`):

```solidity
for (uint8 i = 0; i < targets.length; ++i) {
    targets[i].functionCallWithValue(dataElements[i], values[i]);   // :90 — effects happen first
}
if (getOperationState(id) != OperationState.ReadyForExecution)      // :93 — check happens after
    revert NotReadyForExecution(id);
```

The precondition is enforced *after* the arbitrary external calls. Combined with
self-administration (`:35`) and a permissionless `execute`, the batch can mutate
the very state the subsequent check reads, defeating the timelock entirely.

## Impact
**High/Critical — complete bypass of the timelock and takeover of governed
contracts.** No delay, no proposer role required beforehand; the attacker
manufactures both inside the call.

## Proof of concept
Attacker calls `execute` with a 4-element batch (all `target == timelock` except
where noted):
1. `grantRole(PROPOSER_ROLE, attacker)` — timelock grants it to itself's callee.
2. `updateDelay(0)` — `msg.sender == address(this)` during the self-call, passes.
3. A call to an attacker contract that invokes `schedule(...)` for this exact
   batch (now permitted, since step 1 gave PROPOSER_ROLE), with delay 0 → the
   operation is immediately `ReadyForExecution`.
4. Any further malicious action (e.g. transfer ownership of the governed vault).

When the loop finishes, `getOperationState(id)` is `ReadyForExecution` (scheduled
in step 3 at zero delay), the check on line 93 passes, `executed = true`.

## Recommended mitigation
Enforce checks-effects-interactions: verify `getOperationState(id) ==
ReadyForExecution` **before** executing any target call, and mark
`executed = true` before the external calls. Do not let the readiness invariant
be established by the operations it is meant to gate.
