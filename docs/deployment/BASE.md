# Base Deployment (PoidhV3 + PoidhClaimNFT)

## Prereqs

- Funded deployer EOA on Base
- `POIDH_TREASURY` address confirmed (immutable in `PoidhV3`)
- Deployment parameters confirmed (min bounty + min contribution)
- Explorer API key if using `--verify`

## Deploy

```bash
export BASE_RPC_URL="https://…"
export ETHERSCAN_API_KEY="…"

export DEPLOYER_PK="0x…"
export POIDH_TREASURY="0x…"
export POIDH_START_CLAIM_INDEX=1

# optional
export POIDH_NFT_NAME="poidh claims v3"
export POIDH_NFT_SYMBOL="POIDH3"

forge script script/deploy/Base.s.sol:DeployBase \
  --rpc-url "$BASE_RPC_URL" \
  --private-key "$DEPLOYER_PK" \
  --broadcast \
  --verify
```

## Post-deploy checks

Fill these from the script output:
- `POIDH_V3=0x…`
- `POIDH_NFT=0x…`

```bash
cast call "$POIDH_V3" "treasury()(address)" --rpc-url "$BASE_RPC_URL"
cast call "$POIDH_V3" "poidhNft()(address)" --rpc-url "$BASE_RPC_URL"
cast call "$POIDH_NFT" "poidh()(address)" --rpc-url "$BASE_RPC_URL"
cast call "$POIDH_V3" "MIN_BOUNTY_AMOUNT()(uint256)" --rpc-url "$BASE_RPC_URL"
cast call "$POIDH_V3" "MIN_CONTRIBUTION()(uint256)" --rpc-url "$BASE_RPC_URL"
```

Expected:
- `PoidhV3.poidhNft()` == `POIDH_NFT`
- `PoidhClaimNFT.poidh()` == `POIDH_V3`
- `PoidhV3.treasury()` == `POIDH_TREASURY`
- `PoidhV3.MIN_BOUNTY_AMOUNT()` == `0.001 ether`
- `PoidhV3.MIN_CONTRIBUTION()` == `0.00001 ether`
