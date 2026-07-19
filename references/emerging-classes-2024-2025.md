# Emerging vulnerability classes (2024–2025)

Scouted via web research (subagent). Classes beyond the classic list, each with a
mechanical detection heuristic and a real named exploit/finding. Sources at end.

1. **Transient-storage (EIP-1153) uncleared-slot reuse / low-gas reentrancy** —
   `tstore` slots persist the whole tx and are NOT auto-cleared on return/revert.
   Detect: any fn that `tstore`s a slot with no matching `tstore(slot,0)` on all
   exit paths; one slot holding two semantic values; `tload`/`tstore` (~100 gas)
   enabling reentrancy under a 2300-gas stipend. Real: **SIR.trading, Mar 2025,
   ~$355K** (uncleared slot 0x1).

2. **EIP-7702 delegate storage-collision / init front-run** — an EOA re-delegating
   code keeps prior raw storage; mismatched layouts reinterpret bytes; a
   delegate's `initialize()` is front-runnable. Detect: 7702 delegates must use
   ERC-7201 namespaced storage and atomic setup, not sequential slots + separate
   initializer.

3. **L2 sequencer-uptime / grace-period omission** — Chainlink feeds go stale
   while an L2 sequencer is down. Detect: any L2 contract reading Chainlink that
   does NOT also read the Sequencer Uptime Feed + enforce a GRACE_PERIOD since
   `startedAt`. Real: **BendDAO (C4 2024-07 #24), Revert Lend M-27, Malda 2025**.
   (This is also on our oracle checklist — we keep missing it.)

4. **Cross-chain message replay / missing source-domain binding** — inbound bridge
   msgs processed without a consumed-nonce/GUID mapping AND a `srcChainId`+sender
   check → replay to mint/borrow repeatedly. Detect: trace every
   `lzReceive`/`ccipReceive` to both a `processed` set and a source assertion.
   Real: **Sherlock 2025-05 Lend (#7)** unlimited cross-chain borrow.

5. **Gas-griefing: 63/64 rule + return-bomb DoS** — outer gas sized so the inner
   `call` is starved yet success is recorded; or callee returns a huge payload
   forcing unbounded memory-copy gas. Detect: external `call`s whose success is
   stored without checking forwarded gas; returndata copied without a size cap.
   Real: **Ambire (C4 2023-05) return-bomb**.

6. **Read-only reentrancy on unguarded `view` getters** — a view price/share fn
   (no guard, "can't mutate") re-entered mid-callback while pool state is
   inconsistent → manipulated oracle read. Detect: view fns consumed as
   price/collateral by other protocols, callable during a callback (e.g. Curve
   `remove_liquidity` ETH transfer). Real: **dForce, Feb 2023, $3.64M**;
   Curve `get_virtual_price` LP-oracle class.

7. **Phantom-permit silent success + permit front-run DoS** — `permit()` on a
   non-2612 token whose fallback returns success without setting allowance; or an
   attacker front-runs the permit so the victim's reverts. Detect: `permit` not
   wrapped in try/catch with allowance fallback; mandatory-permit paths for
   arbitrary tokens.

8. **Fee-on-transfer / rebasing balance-cache mismatch** — credits `amount`
   passed rather than `balanceAfter - balanceBefore`; caches raw `balanceOf`
   across actions → accounting drifts above real holdings, last withdrawer
   reverts. Detect: `transferFrom(x,this,amt)` crediting `amt`; cached balances
   across two user actions. Real: **GoGoPool (C4 2022-12 #734), THORChain
   (C4 2024-06 #64)**.

9. **ERC-4337 validation-vs-execution state divergence (ERC-7562)** — paymaster/
   account validation reads mutable shared state that flips between simulation and
   inclusion → bundle DoS / out-of-scope storage. Detect: validation touches only
   ERC-7562-scoped (staked/self) storage, no global-mutable/oracle value.

10. **ERC-4337 UserOp hash malleability / calldata-packing divergence** —
    inconsistent packing yields a different (or colliding) `userOpHash` → a
    signature bound to a different executed op. Detect: EntryPoint hashes the
    packed canonical form; every signed field included and length-bound.

## Sources
- verichains.io/p/eip-1153-transient-storage-save-gas · github.com/ChainSecurity/TSTORE-Low-Gas-Reentrancy · dedaub.com transient-storage impact study
- nethermind.io/blog/eip-7702-attack-surfaces · arxiv 2512.12174
- github.com/code-423n4/2024-07-benddao-findings/issues/24 · docs.chain.link/data-feeds/l2-sequencer-feeds
- github.com/sherlock-audit/2025-05-lend-audit-contest-judging/issues/7
- scsfg.io/hackers/griefing/ · reports.immunefi.com/degate/26529
- chainsecurity.com/blog/curve-lp-oracle-manipulation-post-mortem · quillaudits dForce writeup
- dev.to/ohmygod phantom-deposit · scsfg.io/hackers/signature-attacks/
- github.com/code-423n4/2024-06-thorchain-findings/issues/64 · code-423n4/2022-12-gogopool-findings/issues/734
- zealynx.io/blogs/erc-4337-...six-failure-modes · docs.erc4337.io/paymasters/security-and-griefing · alchemy.com/blog/erc-4337-useroperation-packing-vulnerability
