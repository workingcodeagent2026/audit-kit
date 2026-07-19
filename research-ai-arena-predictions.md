# AI Arena research — BLIND predictions

Pass 2/4. Target: 2024-02-ai-arena (NFT fighters, staking/ELO rewards). Read
RankedBattle (staking/points/claim) + FighterFarm (reroll/transfer/mint). Not
full coverage (12 files; skipped GameItems, VoltageManager, MergingPool details)
— noted honestly. Applying "claim what the read code proves."

## Hypotheses

**B1 (High) — `reRoll` trusts caller-supplied `fighterType`, not the fighter's
stored type.** `reRoll(uint8 tokenId, uint8 fighterType)`: the reroll cap
`require(numRerolls[tokenId] < maxRerollsAllowed[fighterType])` and the attribute
generation `_createFighterBase(dna, fighterType)` both use the **parameter**. A
caller passes any `fighterType` to (a) use a more generous reroll limit and
(b) reroll into another type's element/attribute distribution. Verified in the
read source. CLAIM.

**B2 (High) — Fighter attributes derived from caller-controlled DNA.**
`redeemMintPass` builds `dna = keccak256(abi.encode(mintPassDnas[i]))` where
`mintPassDnas` is a caller-supplied string. Attributes flow from that DNA via
`_createFighterBase`/`createPhysicalAttributes`. A user grinds DNA strings
off-chain and submits one that yields rare attributes → rarity manipulation.
CLAIM.

**B3 (Medium) — `claimNRN` division-by-zero DoS.** The loop does
`claimableNRN += points * nrnDistribution / totalAccumulatedPoints[currentRound]`
with no zero guard. A round with zero total accumulated points reverts the loop;
`numRoundsClaimed` can't advance past it → claims permanently bricked. CLAIM.

**B4 (Medium, lead) — Staking lock may not be enforced on transfer.**
`_ableToTransfer` checks `!fighterStaked[tokenId]`, but `_beforeTokenTransfer`
only calls `super`. If `transferFrom`/`safeTransferFrom` aren't overridden to
call `_ableToTransfer`, staked fighters are transferable. I did not fetch the
transfer overrides — flag, not full claim.

## Note
Target-rich contest (varies difficulty vs. mature PoolTogether). Testing whether
"claim what you can verify" converts read-code bugs (B1) into confident hits.
