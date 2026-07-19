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

## How to extend this file
When you finish a contest, move it to "Done" with the result, and when you find
a subject not represented, add a queue entry. Prefer small-scope (<12 in-scope
files) for clean coverage-gate passes. Use this to bootstrap scope:
`gh api repos/code-423n4/<slug>/git/trees/main?recursive=1 --jq '.tree[].path
| select(test("src/.*\\.sol$")) | select(test("test|mock|interface|lib/";"i")|not)'`
