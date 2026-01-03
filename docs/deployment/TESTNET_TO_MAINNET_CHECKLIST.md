# Deployment Runbook Testnet → Mainnet

This is a practical checklist for deploying POIDH v3 and its claim NFT, wiring them, and verifying
everything on explorers.

Primary deploy script:
- `script/Deploy.s.sol` (parameterized)

Related docs:
- Monitoring: `docs/operations/MONITORING.md`
- Emergency procedures: `docs/operations/EMERGENCY_PROCEDURES.md`
- NFT redeploy rationale: `docs/migrations/NFT_REDEPLOYMENT.md`

---

## 0) Prerequisites (Do Not Skip)

### Security readiness

- [ ] External audit complete with no unresolved critical/high issues
- [ ] Code freeze at a specific commit hash (record it in the address registry below)
- [ ] `forge test` passes locally

### Key management

- [ ] Deployment key is secured and has enough gas funds

### Tooling

- [ ] Foundry installed (`forge --version`, `cast --version`)
- [ ] RPC provider(s) ready (at least 2 for redundancy)
- [ ] Explorer API key ready for `--verify` (Etherscan/BaseScan/etc)

---

## 1) Configuration Inputs

### Required env vars

| Var | Meaning | Example |
|---|---|---|
| `RPC_URL` | network RPC | `https://…` |
| `DEPLOYER_PK` | deployer private key | `0x…` |
| `POIDH_TREASURY` | fee recipient | `0x…` |
| `POIDH_START_CLAIM_INDEX` | must be `>= 1` | `1` |

### Optional env vars

| Var | Meaning | Notes |
|---|---|---|
| `POIDH_MIN_BOUNTY_AMOUNT` | minimum bounty amount | defaults to `0.001 ether` in `script/Deploy.s.sol` |
| `POIDH_MIN_CONTRIBUTION` | minimum contribution | defaults to `0.00001 ether` in `script/Deploy.s.sol` |
| `POIDH_NFT_NAME` | claim NFT name | optional (defaults in deploy script) |
| `POIDH_NFT_SYMBOL` | claim NFT symbol | optional (defaults in deploy script) |
| `ETHERSCAN_API_KEY` | explorer key | used by Foundry verification on many chains |

---

## 2) Address Registry (Fill In As You Go)

Record *everything* here so you can reproduce, verify, and debug later.

### Testnet

- Network:
- Commit hash:
- Deployer:
- `PoidhClaimNFT`:
- `PoidhV3`:
- Treasury:
- Deploy tx hash:
- Deploy block:

### Mainnet

- Network:
- Commit hash:
- Deployer:
- `PoidhClaimNFT`:
- `PoidhV3`:
- Treasury:
- Deploy tx hash:
- Deploy block:

---

## 3) Testnet Dry Run (Strongly Recommended)

### 3.1 Deploy + verify

```bash
export RPC_URL=...
export DEPLOYER_PK=...
export POIDH_TREASURY=0x...
export POIDH_START_CLAIM_INDEX=1

export POIDH_MIN_BOUNTY_AMOUNT=1000000000000000
export POIDH_MIN_CONTRIBUTION=10000000000000
export ETHERSCAN_API_KEY=...

forge script script/Deploy.s.sol:Deploy \
  --rpc-url "$RPC_URL" \
  --private-key "$DEPLOYER_PK" \
  --broadcast \
  --verify
```

### 3.2 Sanity-check wiring (read-only)

```bash
cast call $POIDH_V3 "treasury()(address)" --rpc-url "$RPC_URL"
cast call $POIDH_V3 "poidhNft()(address)" --rpc-url "$RPC_URL"
cast call $POIDH_NFT "poidh()(address)" --rpc-url "$RPC_URL"
```

Expected:
- `PoidhV3.poidhNft()` matches your deployed NFT address
- `PoidhClaimNFT.poidh()` matches your deployed `PoidhV3` address
- `PoidhV3.treasury()` matches `POIDH_TREASURY`

## 4) Mainnet Deployment (Runbook)

Use the *exact same steps* as testnet.

Additional mainnet-specific checks:

- [ ] Confirm chainId and RPC points at intended network
- [ ] Confirm treasury is correct and controlled
- [ ] Confirm immutable wiring (no admin keys or ownership transfers)
- [ ] Confirm monitoring is configured immediately after deployment

---

## 5) Post-Deployment Checklist (Day 0–7)

- [ ] Verify contracts on explorer(s) (bytecode + constructor args)
- [ ] Publish address registry (website/docs) with links to explorers
- [ ] Enable Defender/Tenderly monitors (see `docs/operations/MONITORING.md`)
- [ ] Run a small “real flow” smoke test (small bounty → claim → accept → withdraw)
- [ ] Confirm indexer/subgraph is ingesting all v3 events
- [ ] Announce mainnet launch and bug bounty program
