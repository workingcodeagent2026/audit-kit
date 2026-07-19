# Regression test — does the SOURCE rule catch Basin H-02?

**Setup:** In pass 7 (Basin) I MISSED H-02, a decimals High, by clearing the
downstream scaling math (`getScaledReserves`) without opening the function that
PRODUCES the decimals (`decodeWellData`). After the deep-research playbook added
the SOURCE rule ("open and read every unit's origin function"), re-ran it on the
exact skipped function.

**The bug, now read directly:**
```solidity
function decodeWellData(bytes memory data) ... {
    (uint256 decimal0, uint256 decimal1) = abi.decode(data, (uint256, uint256));
    if (decimal0 == 0) { decimal0 = 18; }
    if (decimal0 == 0) { decimal1 = 18; }   // <-- checks decimal0 twice; decimal1 never defaults
    ...
}
```
Copy-paste bug: the second condition should be `decimal1 == 0`. A token with
`decimal1 == 0` (the "assume 18" sentinel) keeps 0, then
`getScaledReserves` does `reserves[1] * 10**(18 - 0)` = ×1e18 over-scaling →
broken pricing. = Code4rena H-02.

**Result: CAUGHT on sight.** The SOURCE rule converts this from an invisible
downstream-cleared miss into an obvious 2-line defect. The fix is validated
against the exact failure that motivated it.

**Caveat (honesty):** this is a regression test with a known answer, not a blind
hit — it proves the *procedure* catches the bug when applied, not that I'd have
independently applied it. The real test is a fresh blind pass with the playbook
active (queued in curriculum.md).
