# Basin (Stable2) research — BLIND predictions

Pass 4/4. Target: 2024-07-basin, the newly-added `Stable2` stableswap well
function (Curve-style Newton iteration + a price lookup table). Read
calcLpTokenSupply / calcReserve / calcRate / calcReserveAtRatioSwap. Partial
coverage (21 files; the LUT `Stable2LUT1` and MultiFlowPump not fully read) —
honest note. New code = likely bug site.

## Unit-audit result (mechanical, per the Revert Lend lesson)
Decimals: `getScaledReserves` scales to 18; `calcReserve` scales back by
`10**(18 - decimals[j])`. Box-checked both directions — consistent, no mismatch.
`calcRate` re-scales already-scaled reserves via `abi.encode(18,18)` → idempotent
(10**0=1). No decimal bug found here.

## Hypotheses

**S1 (Medium) — `calcLpTokenSupply` silently returns on non-convergence.**
The 255-iteration loop, if it never converges, **falls through and returns the
last `lpTokenSupply`** — no revert. Contrast `calcReserve`, which
`revert("did not find convergence")`. So LP supply (used in minting/pricing) can
be a wrong, unconverged value under adversarial/extreme reserves. Asymmetry
between two sibling functions (predictor-vs-executor family). Concrete: absent
revert after the loop.

**S2 (Medium, lead) — LUT-boundary inaccuracy in `calcReserveAtRatioSwap`.**
The reserve-at-ratio uses `ILookupTable.getRatiosFromPriceSwap(targetPrice)` and
interpolates between `lowPrice/highPrice`. At extreme target prices (near LUT
boundaries) interpolation may be inaccurate or revert, corrupting the pump
oracle / capped-reserve output. LUT file not fully read — flag, not full claim.

## Leads NOT claimed
- Newton rounding (`dP`, integer division) could bias LP supply by a few wei —
  looks within tolerance (±1 convergence). No claim without a concrete exploit.

## Note
Hard math target, final pass. Testing that the mechanical unit-audit correctly
CLEARS the decimals (avoiding the Revert Lend over-clearing error while not
inventing a false decimal bug) and that a real asymmetry (S1) surfaces.
