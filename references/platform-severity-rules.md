# Platform severity & validity rules (read BEFORE every audit)

Judging rules are part of the target. A valid-on-one-platform finding can be
auto-invalid on another. Read this + the contest README before predicting, and
PRE-FILTER predictions by the platform's rules.

## Quick comparison
| | Sherlock | Code4rena | Immunefi |
|---|---|---|---|
| Model | contest (pre-launch) | contest (pre-launch) | bounty (LIVE code) |
| Valid = | loss of funds (H/M only) | assets lost/at-risk or availability | impact-based 4-tier |
| High | direct loss, NO major external conditions (>1% & >$10) | assets stolen/lost directly, valid attack path (no hand-wavy) | Critical: theft/freeze/insolvency/mint |
| Medium | loss under external conditions, or core-fn break (>0.01% & >$10) | function/availability impact or conditional leak | operational failure/griefing |
| Admin | **trusted by default** — invalid unless breaks EXPLICIT README restriction | trusted; reckless mistakes invalid; centralization → QA | downgraded if needs elevated privilege |
| Needs | — | root cause in-scope | **PoC / demonstrated impact** |

## Sherlock AUTO-INVALID list (memorize — these lost us Y2/Y4 on Yieldoor)
Do NOT submit on Sherlock:
1. Gas optimizations · 2. Incorrect event values · 3. Zero-address checks ·
4. Input validation (unless major malfunction) · 5. **Admin call-order mistakes** ·
6. Admin/contract blacklisting effects · 7. Front-running initializers (no
irreversible damage) · 8. UX-only · 9. User self-harm ·
10. Non-protocol airdrop/reward loss · **11. Stale-price / Chainlink-completeness
recommendations** · 12. Chain re-org / liveness · 13. ERC721 unsafe-mint ·
14. Future integration issues · 15. Non-standard token behavior (unless README
says so) · **16. Sequencer-downtime assumptions.**
→ Our oracle-checklist Highs (staleness #11, sequencer #16) are DEAD on Sherlock.

## Sherlock hierarchy of truth
README (Q&A defines invariants) > code comments > default guidelines > public
statements (only if <24h before end). Read the README Q&A FIRST — it decides
admin-trust and which invariants count.

## Code4rena downgrades to QA (don't over-rate)
Centralization/admin privilege misuse → QA. User-mistake findings → QA at best.
Future-code speculation → invalid unless root cause is in-scope NOW.

## Immunefi specifics (live-code bounties)
Impact-centric, not likelihood. Critical = direct theft / permanent freeze /
governance takeover / unauthorized mint / insolvency. Needs a real PoC on
deployed code — much higher bar than a written contest finding. Elevated-privilege
or uncommon-interaction requirements DOWNGRADE severity.

## Pre-audit calibration procedure (apply per contest)
1. Identify the platform → load its rules (above).
2. Read the contest README/Q&A → note trusted roles, stated invariants, scope.
3. When predicting, tag each finding with the platform verdict: would it be
   auto-invalid / QA / downgraded here? DROP or downgrade accordingly BEFORE
   submitting. (On Sherlock: drop staleness/sequencer/admin-config/non-standard-
   token findings unless the README explicitly opens them.)
