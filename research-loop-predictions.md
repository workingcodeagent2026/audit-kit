# LoopFi PrelaunchPoints — BLIND predictions

Batch pass A. Target: 2024-05-loop (1 file, 296 nSLOC, 1H/0M). FULL coverage.
Playbooks active. Points/locking contract that swaps LRT→ETH via a 0x exchange
proxy on claim, then deposits to lpETH.

## Hypotheses

**L1 (High) — `_claim` credits the whole contract ETH balance, not the swap
delta.** Non-ETH path: after `_fillQuote` (which computes `boughtETHAmount` as a
balance delta), `_claim` sets `claimedAmount = address(this).balance` — the TOTAL
ETH held — then `lpETH.deposit{value: claimedAmount}`. Any stray/other-user ETH
in the contract is swept to this claimer → over-claim / theft of contract ETH.
Should use the `_fillQuote` delta, not `address(this).balance`. CLAIM (read the lines).

**L2 (Medium) — `_fillQuote` leaves residual approval.** `require(_sellToken.
approve(exchangeProxy, _amount))` then swaps, never resets to 0. If the swap
consumes less than `_amount`, allowance persists to the (trusted, but still)
exchangeProxy. Also `approve` (not forceApprove) → non-standard tokens revert
(units-playbook pattern #? / phantom-permit family).

**L3 (Medium, lead) — swap-calldata validation gaps.** `_validateData` allows
`recipient == address(0)`, and the UniswapV3 branch requires `outputToken == WETH`
while the TransformERC20 branch requires `== ETH` — the post-swap handling reads
`address(this).balance` (ETH), so a WETH-output swap that isn't unwrapped yields
0 delta (masked by L1's total-balance bug). Possible validation bypass /
mis-routing. Flag; the 0x calldata decoding (`_decodeUniswapV3Data`) not fully read.

## Coverage / playbook note
Full file read. Applied caller-controlled-param lens (the `_data` calldata to a
proxy) and the balance-delta-vs-total accounting check. L1 is the confident High.
