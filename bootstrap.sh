#!/usr/bin/env bash
# Bootstrap one training-loop pass: list in-scope contracts for a Code4rena
# contest so the coverage gate can be satisfied before any prediction.
# Usage: ./bootstrap.sh 2024-03-revert-lend
set -euo pipefail
slug="${1:?usage: bootstrap.sh <code4rena-slug, e.g. 2024-03-revert-lend>}"
echo "== in-scope .sol (excluding test/mock/interface/lib) for $slug =="
gh api "repos/code-423n4/$slug/git/trees/main?recursive=1" \
  --jq '.tree[].path
        | select(test("\\.sol$"))
        | select(test("src/|contracts/"))
        | select(test("test|mock|interface|lib/|script/";"i")|not)'
echo
echo "== report: https://code4rena.com/reports/$slug (do NOT open until predictions written) =="
