#!/usr/bin/env bash
# sweep.sh — cross-protocol bug-signature sweep.
# Encodes confirmed bugs as greppable signatures (see signatures/patterns.md).
# Every hit is a LEAD to verify by hand, never an auto-finding.
# Usage: ./sweep.sh <path-to-cloned-repo>   (reads only .sol under src/contracts)
set -uo pipefail
dir="${1:?usage: sweep.sh <repo-dir>}"
sol() { grep -rnE "$1" "$dir" --include='*.sol' 2>/dev/null \
        | grep -viE '/(test|mock|lib|node_modules|script)/' | grep -viE '\.t\.sol|\.s\.sol'; }

hit() { local n="$1" desc="$2" pat="$3"; local out; out="$(sol "$pat")";
  if [ -n "$out" ]; then echo "── $n  $desc"; echo "$out" | head -12; echo; fi; }

echo "### Signature sweep: $dir"
echo "### Each hit = a LEAD. Open it, apply the playbook, verify. Not a finding."; echo

hit S1 "divide by .decimals() (units: count vs 10**dec) — Yieldoor" \
    '/[[:space:]]*[A-Za-z0-9_.()]*\.decimals\(\)'
hit S2 "getReserves() near a price/value calc (spot-oracle) — Abracadabra" \
    '\.getReserves\(\)'
hit S3 "balanceOf(address(this)) as an amount (LoopFi H-01)" \
    'balanceOf\([[:space:]]*address\(this\)[[:space:]]*\)'
hit S4 "latestRoundData with updatedAt commented/ignored (staleness)" \
    'latestRoundData\('
hit S5 "&& between two '<' checks in a solvency/flashloan revert (logic && vs ||)" \
    '<[^;]*&&[^;]*<'
hit S6 "onERC721Received / flashloan callback (reentrancy — needs CEI trace)" \
    'onERC721Received|onFlashLoan|FlashLoanCall'
hit S7 "array .push( — unbounded-growth griefing (Curves H-01)" \
    '\.push\('
hit S8 "max/preview/limit fn — check it matches the executor (predictor-vs-executor)" \
    'function (max|preview|calculateMin|calculateMax)'

echo "### Done. Triage the leads above with signatures/patterns.md + the playbooks."
