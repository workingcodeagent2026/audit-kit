# [High] Governance actions are gated by flash-loanable voting power, allowing a single-tx capture that drains the pool

*Warm-up — Damn Vulnerable DeFi v4 `SelfiePool.sol` (+ `SimpleGovernance`).
Verifiable against the public solution. Class: privileged action gated by a
balance/snapshot that is rentable within one transaction.*

## Summary
`emergencyExit` drains the entire pool and is protected only by `onlyGovernance`
(`:70-75`, `:24-28`) — caller identity, not legitimacy. Governance proposals are
authorized by voting power derived from the pool's own token, and `flashLoan`
(`:49-68`) will lend out the *entire* token balance for zero fee. An attacker
flash-borrows the supply, uses it to pass a proposal calling
`emergencyExit(attacker)`, and returns the loan — capturing governance for the
price of gas.

## Finding description
`onlyGovernance` confirms `msg.sender == address(governance)` but nothing
confirms the *governance decision* was made by legitimate, non-transient
stake. Because `SelfiePool.flashLoan` hands out `token.balanceOf(pool)` (`:35-40`,
`:58`) with no fee and no restriction, an attacker can momentarily hold enough
voting power to queue a proposal.

**Cross-file dependency I would confirm before finalizing:** this is only
exploitable if `SimpleGovernance` snapshots voting power from a source the
attacker controls during the flash loan (e.g. a `getVotes`/`balanceOf` read, or
an ERC20Votes checkpoint taken at proposal time) *without* a delay between
acquiring tokens and being able to propose/execute. If `SimpleGovernance`
required votes held across a past checkpoint or enforced a timelock longer than
one tx with no way to hold borrowed tokens across it, the severity drops. The
DVD design does not — proposals queue on current voting power and execute after
a fixed action delay the attacker simply waits out, holding nothing.

## Impact
**High — total loss of pool funds.** Governance, and therefore `emergencyExit`,
is capturable by any actor with access to the flash loan (i.e. anyone).

## Proof of concept
1. Attacker flash-borrows the full governance-token balance from `SelfiePool`.
2. Within the callback, with majority voting power, queues a governance action:
   `SelfiePool.emergencyExit(attacker)`.
3. Repays the flash loan (same tx) — attacker now holds nothing.
4. After the governance action delay, attacker executes the queued proposal;
   `emergencyExit` transfers the entire pool balance to the attacker.

## Recommended mitigation
Do not gate privileged actions on instantaneously-acquirable voting power. Use
snapshot/checkpoint voting anchored to a block *before* proposal creation, add a
timelock that exceeds any single transaction and spans the acquire-to-execute
window, and/or exclude flash-loaned balances (e.g. require votes to have been
held across a prior checkpoint). Reconsider whether a pool should lend the very
token that governs it.
