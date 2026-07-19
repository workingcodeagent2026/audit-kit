# [High] `_buyOne` reads `ownerOf` *after* transferring the NFT, paying the sale price to the buyer instead of the seller

*Warm-up — Damn Vulnerable DeFi v4 `FreeRiderNFTMarketplace.sol`. Verifiable
against the public solution. Class: ordering assumption — state read after the
state has already changed (our "who actually gets paid?" value-flow check).*

## Summary
`_buyOne` transfers the NFT to `msg.sender` first, then computes the payment
recipient as `token.ownerOf(tokenId)` — which is now the buyer. The marketplace
pays the sale price **to the buyer**, refunding them from its own balance.
Combined with a shared `msg.value` across `buyMany`, an attacker acquires every
listed NFT for free and drains the marketplace's ETH.

## Finding description
`_buyOne` (`:94-114`):

```solidity
_token.safeTransferFrom(_token.ownerOf(tokenId), msg.sender, tokenId);  // :108 — NFT now owned by buyer
payable(_token.ownerOf(tokenId)).sendValue(priceToPay);                 // :111 — ownerOf == buyer now
```

The payment on line 111 re-reads `ownerOf`, but line 108 already moved the token
to `msg.sender`. So the "seller" payout goes to the buyer. The buyer's own
`msg.value` sits in the contract, and `priceToPay` is sent back to them — net,
the marketplace pays the buyer to take the NFT.

Second, compounding bug: `buyMany` (`:87-92`) loops `_buyOne` while each
iteration checks only `msg.value < priceToPay` (`:100`). `msg.value` is fixed
for the whole call and never decremented, so one payment of a single price
satisfies the check for *every* NFT in the batch.

## Impact
**High — theft of all listed NFTs and drain of the marketplace's ETH.** An
attacker pays one item's price (via flash loan if needed), receives all NFTs,
and is refunded more than they paid.

## Proof of concept
Marketplace holds ETH and lists 6 NFTs at 15 ETH each.
1. Attacker calls `buyMany([0,1,2,3,4,5])` with `msg.value = 15 ether`.
2. Each `_buyOne`: `msg.value (15) >= priceToPay (15)` passes every iteration
   (never decremented); NFT transfers to attacker; `ownerOf` now = attacker;
   `sendValue(15 ether)` pays the attacker.
3. Attacker ends with all 6 NFTs and more ETH than they sent (each iteration
   returns 15 ETH from the marketplace's balance).

## Recommended mitigation
Capture the seller address *before* transferring the NFT and pay that cached
address. Decrement a running `msg.value` (or require `msg.value ==` the summed
prices) so each purchase is individually funded. Apply checks-effects-
interactions: compute payment recipient and amount, effect internal state, then
transfer NFT and funds.
