# Chain models & code portability — where the bug-propagation thesis lives

Grounding the "functions repeat across chains, so bugs repeat" thesis in how the
networks actually work. The honest conclusion: the thesis lives on the **EVM
family**, and Bitcoin is mostly outside the game.

## BTC vs ETH — the axis that matters
| | Bitcoin | Ethereum (EVM) |
|---|---|---|
| Model | UTXO (unspent outputs) | Account + persistent contract state |
| Programmability | **Script** — non-Turing-complete, stack-based, no loops, no persistent state | **EVM** — Turing-complete, Solidity/Vyper, rich state |
| "Smart contracts" | minimal (multisig, timelocks, HTLCs) | full programmable protocols |
| Reusable-vuln surface | **tiny** — barely any forkable contract code | **huge** — protocols forked constantly |
| Audit/bounty market | almost none on L1 | ~95%+ of the market |

**So Bitcoin L1 is out of your game** — no programmability means no forkable
vulnerable functions. (Emerging exceptions add programmability *on top* of BTC:
Stacks, RSK/Rootstock, BitVM, Ordinals/Runes tooling — and THOSE can have bugs,
but they're their own smart-contract environments, not BTC Script.)

## The thesis, sharpened
Your edge needs code that is (a) **programmable enough to have bugs** and
(b) **portable enough to be copied**. That is the **EVM family**: Ethereum + every
EVM L2/sidechain (Base, Arbitrum, Optimism, Polygon, BSC, Avalanche C-chain, …),
plus other smart-contract ecosystems (Solana/Rust, Move/Aptos-Sui, Cosmos/
CosmWasm). Within EVM, the SAME Solidity/bytecode runs everywhere → a protocol on
8 chains carries its bug on all 8 → **a patch that lands on one chain but misses
another is a live, findable bug.** That is "networks differ but functions don't"
made concrete.

## The confirmed cross-chain bug class (real paid findings)
"Same contract, different chain semantics" is a documented, rewarded class:
- **PUSH0 opcode** — Solidity ≥0.8.20 emits PUSH0 (Shanghai); chains without it
  (older Arbitrum, some L2s) can't deploy → DoS. Confirmed: Sherlock
  2024-04-titles #340, 2024-06-boost-aa-wallet #179, timeline-aggregation L-03.
- **`block.number` semantics** — on Arbitrum returns the L1-ancestor block, not
  the Arbitrum block; a contract assuming Ethereum block cadence mis-times.
  Confirmed: Sherlock 2023-10-real-wagmi #173.
- **`block.timestamp`, sequencer uptime, reorg/liveness** — differ per L2 (our
  emerging-classes L2-sequencer entry).
- **Precompiles / opcodes** — exist on one chain, absent on another.
- **Gas-cost differences** — shift the 63/64-rule and DoS thresholds.
- **Bridged-token decimals/behavior** — the "same" token differs across chains.

## How this extends the sweep tool
Two new sweeping strategies (see signatures/patterns.md, sweep.sh):
1. **Cross-chain patch-gap sweep:** take a protocol deployed on N chains; diff its
   verified source per chain; a fix present on chain A but absent on chain B = a
   live bug on B. (Same code, different chain = the thesis in its purest form.)
2. **Chain-assumption sweep:** grep a codebase for `block.number`, `block.timestamp`,
   PUSH0-era pragma (`^0.8.2x`), precompile addresses, hardcoded gas — then ask
   "does this hold on the chain(s) it's actually deployed to?" Confirmed-finding
   class, often Medium.

## Bottom line for the money thesis
Skip Bitcoin. Hunt the EVM family (and later Solana/Move/Cosmos). The single most
tractable version of your idea: **a protocol live on multiple EVM chains where a
patch or a chain-assumption didn't propagate.** Same function, different network,
unfixed bug — exactly what you predicted.
