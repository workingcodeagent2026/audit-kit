# Audit Kit

A working audit methodology plus a portfolio of verified practice findings,
built on the "economic-truth" lens: hunt the logic bugs tools miss (oracle
trust, reward accounting, value-flow, ordering) before sweeping the classics.

- **METHODOLOGY.md** — pass order + the nine-trap → vulnerability-class map.
- **FINDING_TEMPLATE.md** — Code4rena/Cantina/Sherlock finding format.
- **warmup-\*.md** — full findings on real Solidity source, each verifiable
  against a public solution (Damn Vulnerable DeFi v4).

## Portfolio (9 classes)

| Finding | Vulnerability class | Sev |
|---|---|---|
| Puppet | Spot-balance oracle manipulation | High |
| Truster | Arbitrary caller-controlled external call | High |
| Unstoppable | Raw-balance vs. accounting invariant DoS | Med |
| Side Entrance | Two ledgers measuring the same value | High |
| Selfie | Flash-loanable governance capture | High |
| The Rewarder | Payout loop vs. claimed-accounting desync | High |
| Free Rider | Ordering bug — state read after mutation | High |
| Climber | CEI violated at the authorization layer | High |
| Naive Receiver | Costly action without beneficiary consent | High |

## The through-line

Every finding came from one question: **what does this code assume that the
world does not guarantee?** That is the same discipline behind the trap-aware
keeper fleet ([../beefy-harvester](https://github.com/workingcodeagent2026/trap-aware-keeper-fleet)) —
there it caught fake yields; here it catches fake safety. Promise vs. receipt,
oracle vs. spot, intent vs. value-flow: verify the leg, don't trust the label.
