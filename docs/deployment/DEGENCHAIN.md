# Degenchain Deployment (PoidhV3 + PoidhClaimNFT)

## Prereqs

- Funded deployer EOA on Degenchain
- `POIDH_TREASURY` address confirmed (immutable in `PoidhV3`)
- Deployment parameters confirmed (min bounty + min contribution)

## Deploy

```bash
export DEGEN_RPC_URL="https://…"

export DEPLOYER_PK="0x…"
export POIDH_TREASURY="0x…"
export POIDH_START_CLAIM_INDEX=1

# optional
export POIDH_NFT_NAME="poidh claims v3"
export POIDH_NFT_SYMBOL="POIDH3"

forge script script/deploy/Degenchain.s.sol:DeployDegenchain \
  --rpc-url "$DEGEN_RPC_URL" \
  --private-key "$DEPLOYER_PK" \
  --broadcast
```

## Post-deploy checks

Fill these from the script output:
- `POIDH_V3=0x…`
- `POIDH_NFT=0x…`

```bash
cast call "$POIDH_V3" "treasury()(address)" --rpc-url "$DEGEN_RPC_URL"
cast call "$POIDH_V3" "poidhNft()(address)" --rpc-url "$DEGEN_RPC_URL"
cast call "$POIDH_NFT" "poidh()(address)" --rpc-url "$DEGEN_RPC_URL"
cast call "$POIDH_V3" "MIN_BOUNTY_AMOUNT()(uint256)" --rpc-url "$DEGEN_RPC_URL"
cast call "$POIDH_V3" "MIN_CONTRIBUTION()(uint256)" --rpc-url "$DEGEN_RPC_URL"
```

Expected:
- `PoidhV3.poidhNft()` == `POIDH_NFT`
- `PoidhClaimNFT.poidh()` == `POIDH_V3`
- `PoidhV3.treasury()` == `POIDH_TREASURY`
- `PoidhV3.MIN_BOUNTY_AMOUNT()` == `1 ether` (1 DEGEN)
- `PoidhV3.MIN_CONTRIBUTION()` == `1 ether` (1 DEGEN)
