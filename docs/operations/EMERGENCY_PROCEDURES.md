# Emergency Procedures (No Onchain Pause)

POIDH v3 has no admin pause and no “sweep” function by design. Emergency response is therefore:

1) **coordination + communication**, and
2) helping users move funds using normal flows (cancel + withdraw), and
3) deploying a patched version if needed (full redeploy).

## Emergency Levers (What You Can Actually Do)

### Onchain levers

None. The contracts are fully immutable and have no admin wiring functions.

### Offchain levers

- Pause/disable frontend flows (create/join/claim/accept).
- Pin incident banner + force acknowledgements.
- Coordinate comms (Discord/Twitter/blog) with clear user instructions.
- Rate-limit / gate claim submission in the UI (mitigates “claim spam” even if onchain allows it).

## Immediate Response Checklist (First 60 Minutes)

- [ ] Triage: confirm if issue is real (repro tx, chain data, logs).
- [ ] Classify severity (see `docs/operations/INCIDENT_RESPONSE.md`).
- [ ] Freeze UI (at minimum: disable “create bounty” and “create claim”).
- [ ] Notify core team.
- [ ] Decide whether to redeploy (new NFT + PoidhV3) and update UI/indexer.
- [ ] Draft public message with concrete user actions (cancel bounties / withdraw).

## User Fund Safety Guidance (If Funds May Be At Risk)

Because funds are escrowed in `PoidhV3`, the safest “get funds out” path is via normal flows:

- Issuers:
  - Cancel solo bounties via `cancelSoloBounty(bountyId)`
  - Cancel open bounties via `cancelOpenBounty(bountyId)`
  - Then withdraw credited funds via `withdraw()` / `withdrawTo()`

- Contributors (open bounties):
  - If issuer cancels: `claimRefundFromCancelledOpenBounty(bountyId)` then `withdraw()`
  - If not voting: `withdrawFromOpenBounty(bountyId)` then `withdraw()`

## Suggested “Stop Claim Minting” Action (If Needed)

There is no onchain kill switch. The only option is to:
- pause the UI and indexer,
- deploy a patched NFT + PoidhV3 pair,
- update the UI to the new addresses.
