# Curriculum — finished contests by subject & difficulty

The training syllabus. Pick deliberately: match the subject to a class you want
to drill, and vary difficulty (findings count) to control confounds. "Findings"
= High+Medium count (rough difficulty / bug-density proxy). All are Code4rena
`code-423n4/<slug>` repos with public reports at `code4rena.com/reports/<slug>`.

## Done (blind-graded)
| Contest | Subject | Findings | Our result |
|---|---|---|---|
| 2024-05-bakerfi | Leveraged staking vault, oracles (Chainlink/Pyth) | 4H/8M | 0 hits — missed decimals High |
| 2024-01-canto | Reward accounting (MasterChef), epochs | 2H/2M | 1 Med hit + 1 partial |
| 2024-04-dyad | CDP stablecoin, kerosine collateral, liquidation | 10H/9M | 2 High + 1 Med hit (+1 High hedged) |

## Queue — by subject (drill the class you're weak in)

**Oracles / pricing (decimals, staleness, TWAP, sequencer)** — our recurring miss
- 2024-03-revert-lend — Uniswap V3 position lending (~11 files)
- 2024-02-spectra — yield tokenization, PT/YT pricing (~18 files)

**Liquidation / lending math (incentives, bad debt, CR)** — DYAD-missed classes
- 2024-06-size — order-book lending, liquidation
- 2024-07-karak — restaking (larger)

**Reward / accounting desync (claim loops, share math)** — Canto family
- 2024-03-pooltogether — prize savings, share accounting
- 2024-01-decent — cross-chain, accounting

**AMM / swap math (rounding, invariants, slippage)**
- 2024-07-basin — AMM wells (~28 files)
- 2024-02-ai-arena — ELO/accounting (small, famous unit bug)

**Governance / voting / timelock**
- 2024-03-dittoeth — order-book + governance

**Fresh queue (subagent-scouted & verified — ranked for units/liquidation drill)**
| slug | domain | scope | H/M | why |
|---|---|---|---|---|
| 2024-05-loop | leveraged-staking points | 1 file, 296 nSLOC | 1H/0M | ideal 100%-coverage warm-up |
| 2024-03-ondo-finance | RWA stablecoin (rebasing decimals) | 3 files, 851 | 1H/4M | units/rebase drill |
| 2024-02-spectra | yield tokenization (PT/YT rate math) | 7 files, 976 | 0H/2M | decimal/rate math |
| 2024-01-curves | bonding-curve fee/pricing math | 5 files, 660 | 5H/10M | unit math, bug-dense |
| 2024-11-ethena-labs | stablecoin mint/redeem accounting | 4 files, 665 | 0H/2M | collateral accounting |
| 2024-06-size | credit/lending marketplace | 32 files, 2.6k | 4H/13M | STRONGEST liquidation+units target (decimal-mismatch reward bugs) |
| 2024-03-abracadabra-money | CDP + AMM oracle | ~22 files | public | CDP/oracle stretch |
| 2024-05-predy | perps/gamma on Uni v3 | 54 files | 4H/8M | liquidation depth stretch |

Also-scouted (earlier): 2024-01-decent, 2024-01-salty, 2024-08-wildcat, 2024-06-vultisig.
Priority order for the next batch: loop (warm-up) → ondo/spectra/ethena (unit-source
drill w/ the units playbook) → size (liquidation+units, weak-classes playbook) →
curves (bug-dense unit math). Apply references/*-playbook.md on every pass.

## How to extend this file
When you finish a contest, move it to "Done" with the result, and when you find
a subject not represented, add a queue entry. Prefer small-scope (<12 in-scope
files) for clean coverage-gate passes. Use this to bootstrap scope:
`gh api repos/code-423n4/<slug>/git/trees/main?recursive=1 --jq '.tree[].path
| select(test("src/.*\\.sol$")) | select(test("test|mock|interface|lib/";"i")|not)'`
