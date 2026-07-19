# How smart contracts work — for auditors (the machine & where it breaks)

Not a tutorial. Each mechanic of the EVM, paired with the bug class it enables and
our confirmed example. Understand the machine → you see the bugs. Every class in
knowledge-base.md traces to one of these.

## 1. The execution model: atomic, deterministic state machine
A contract = **code (immutable) + storage (persistent)** at an address. A
transaction runs top-to-bottom, deterministically, and is **atomic**: if it
reverts, EVERY state change unwinds as if it never happened.
→ **Why bugs live here:** a `require`/`revert` anywhere rolls back the whole call.
A malicious callee reverting bricks the caller (griefing DoS — Curves H-03,
Aegis whale-grief). "Can someone force this to revert?" is always a question.

## 2. Storage layout: 32-byte slots, sequential, mappings hashed
State variables occupy sequential 32-byte **storage slots**; mappings/arrays live
at hashed offsets. **memory** (temporary, per-call) and **calldata** (read-only
input) are separate and wiped after the call.
→ **Why bugs live here:** two contracts sharing storage via `delegatecall` must
have identical layouts or bytes get reinterpreted (**storage collision** —
EIP-7702/proxy class). Storage *packing* (uint128+uint128 in one slot) → unsafe
downcast bugs (Balancer). Uninitialized proxy storage → takeover.

## 3. Accounts & context: msg.sender, tx.origin, msg.value
EOAs (users) and contracts both have addresses. `msg.sender` = immediate caller;
`tx.origin` = original EOA; `msg.value` = ETH sent. In a `delegatecall`, `msg.sender`
and storage stay the CALLER's.
→ **Why bugs live here:** auth on `tx.origin` → phishing (any contract you call
can act as you). Auth checking *identity* not *legitimacy* → flash-loanable votes
(Selfie), or `isValidDNft` vs `isDNftOwner` (DYAD H-03). caller-supplied params
trusted as truth (AI Arena H-04).

## 4. External calls: call / delegatecall / staticcall
`call` runs the callee's code in ITS context. **`delegatecall` runs the callee's
code in YOUR storage/context** (how proxies upgrade — and how they die).
`staticcall` forbids state change. Low-level `call` returns `(bool success, bytes)`
— **an unchecked failure is silent**.
→ **Why bugs live here:** arbitrary `target.call(data)` with attacker input →
total drain (Truster). `delegatecall` to attacker code → storage takeover. Copying
returndata unbounded → return-bomb DoS. Unchecked return → funds "sent" that weren't.

## 5. The reentrancy mechanism (the #1 class, explained by #1 + #4)
Because an external call hands control to arbitrary code **before your function
finishes**, the callee can re-enter you while your state is half-updated.
→ **Fix pattern (CEI):** Checks → Effects (update state) → Interactions (external
call) LAST. Violated at the logic layer (Free Rider, Side Entrance) or the
**authorization** layer (Climber: runs calls before the readiness check). Also
**read-only reentrancy**: a `view` price fn re-entered mid-callback returns a
manipulated value (dForce $3.6M).

## 6. Integers only — no floats (the entire units/precision family)
The EVM has **no decimals/floats**. "1.5" is faked with fixed-point scaling: WAD
(1e18), RAY (1e27), bps (1e4). Division **truncates toward zero**.
→ **Why bugs live here — our #1 class:** token `decimals()` mismatches (8 vs 18),
dividing by `.decimals()` instead of `10**decimals` (Yieldoor), div-before-mul
precision loss (Canto M-02), wrong rounding direction (SudoSwap), round-to-zero
(Cooler), scaling by the wrong power. See units-precision-playbook.md.

## 7. Gas: metered execution + the 63/64 rule
Every opcode costs gas; running out **reverts**. A caller forwards at most 63/64
of remaining gas to a sub-call.
→ **Why bugs live here:** unbounded loops over attacker-growable arrays → OOG DoS
(Curves H-01). Gas-griefing: starve a sub-call so it fails while success is
recorded (Ambire). DoS thresholds shift across chains (cheaper/dearer gas).

## 8. Value & tokens: ETH vs ERC20
ETH moves via `msg.value`/`payable`/`.call{value:}`. **ERC20 is just another
contract** — `transfer`/`transferFrom` + `approve` allowances. The standard is
loosely followed: some tokens take a fee on transfer, rebase, return no bool, or
re-enter (ERC777 hooks).
→ **Why bugs live here:** crediting `amount` instead of measured
`balanceAfter-balanceBefore` (fee-on-transfer accounting), using
`balanceOf(this)` as an authoritative amount (LoopFi H-01), approval race, unchecked
transfer return (Abracadabra M-06).

## 9. Immutability & upgradeability (proxies)
Deployed code is **immutable**. Upgrades use a **proxy** that `delegatecall`s to a
logic contract → the proxy holds state, the logic holds code.
→ **Why bugs live here:** storage-layout collision between versions, uninitialized
implementation, function-selector clashes, unprotected `_authorizeUpgrade`
(Basin H-01). "Who can upgrade, and is the initializer protected?"

## 10. The mempool: public, ordering-manipulable (MEV)
Pending txs are **public before they're mined**, and block builders order them.
Anyone can front-run, back-run, or sandwich.
→ **Why bugs live here:** missing slippage bounds (BakerFi H-04), first-depositor
share inflation via a donation front-run, oracle/price manipulation within a tx
(manipulable-derived-value: Puppet, Abracadabra H-04), "fake availability" races.

## How to use this
When you read a function, ask the mechanic questions: *Can it revert (griefing)?
Does it external-call before finalizing state (reentrancy)? Are units/decimals
scaled right (no floats)? Who's msg.sender vs who should be? Is a balance/ratio
read that an attacker can move within the tx?* The bug classes are just these
mechanics turned into questions.
