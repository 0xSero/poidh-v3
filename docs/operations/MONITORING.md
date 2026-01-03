# Monitoring & Alerting (Defender + Tenderly)

POIDH v3 is intentionally light on admin controls (no onchain pause). Monitoring is therefore
mostly about *detecting issues early*, *triaging quickly*, and *coordinating comms*.

Related runbooks:
- `docs/operations/EMERGENCY_PROCEDURES.md`
- `docs/operations/INCIDENT_RESPONSE.md`

## Goals

- Detect unexpected value movement and anomalous behavior quickly.
- Detect UX-killing griefing patterns (claim spam, slot exhaustion trends).
- Provide enough context to decide: “expected”, “suspicious”, or “incident”.

## Contracts to Monitor

- `PoidhV3` (`src/PoidhV3.sol`)
- `PoidhClaimNFT` (`src/PoidhClaimNFT.sol`)

## High-Signal Events to Alert On

### PoidhV3 events

- `ClaimAccepted` payout + fee credited; should correlate to expected claim resolution.
- `BountyCancelled` issuer cancellation; can indicate distress if frequent/unexpected.
- `Withdrawal` funds leaving pendingWithdrawals (expected but worth threshold alerts).
- `VotingStarted` / `VotingResolved` lifecycle; useful for debugging voting disputes.

### PoidhClaimNFT events

- `Transfer` events (mint-to-escrow and final transfer to bounty issuer).

## OpenZeppelin Defender (Recommended Setup)

### 1) Sentinels

Create Sentinels per network (testnet + mainnet) on:
- `PoidhV3` for: `ClaimAccepted`, `BountyCancelled`, `Withdrawal`
- `PoidhClaimNFT` for: `Transfer` (optional)

Suggested severity and routing:

| Alert | Severity | Route |
|---|---|---|
| `ClaimAccepted` (large bounty) | High | Security + ops channel |
| `Withdrawal` > threshold | High | Ops channel |
| Unusually high `ClaimCreated` rate | Medium | Ops channel |

### 2) “Large withdrawal” thresholds

Pick thresholds based on expected usage. Example starting points:
- Testnet: alert on any `Withdrawal` > 0.1 ETH
- Mainnet: alert on `Withdrawal` > 5 ETH (and also on “spike” patterns)

### 3) “Claim spam” detection

Claim spam is an L2/gas-only griefing vector; it’s about volume.

Options:
- Defender Autotask (cron) that queries “claims created in last N blocks” and alerts if above X.
- Indexer-based alert (TheGraph / custom) that can aggregate by bountyId.

## Tenderly (Recommended Setup)

### 1) Contract import + verification

- Import deployed `PoidhV3` and `PoidhClaimNFT` into the Tenderly project.
- Enable automatic contract verification where possible.

### 2) Alerts

Useful Tenderly alert types:
- “High value transfer” from `PoidhV3` (withdrawals)
- Reverts spike tracking for key methods (can indicate abuse/DoS attempts)

### 3) Simulation in triage

For suspicious txs, simulate:
- The exact calldata against the current chain state

## Minimum “Daily” Ops Checks (Post-Launch)

- Confirm indexer health and freshness (events are being ingested).
- Review withdrawals volume vs expected.
- Review claim creation rate for spam patterns.
