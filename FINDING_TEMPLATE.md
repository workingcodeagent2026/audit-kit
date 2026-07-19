# [Severity: High/Medium/Low] Title — concise claim

## Summary
One sentence: what is wrong and what it lets an attacker do.

## Finding description
The mechanism. Reference exact `file.sol:line`. Explain the incorrect
assumption in the code and why it does not hold.

## Impact
Concrete consequence. Who loses what, under what conditions. Tie to severity:
- High: direct loss of funds / theft / permanent freeze, plausibly reachable.
- Medium: loss under specific conditions, or value leak, or griefing with cost.
- Low: no fund impact but incorrect behavior / spec violation.

## Proof of concept
Concrete path: exact inputs and state → the wrong result. A failing test or
a numbered step sequence. Numbers, not adjectives.

## Recommended mitigation
The specific code change. Show the diff or the exact check to add.
