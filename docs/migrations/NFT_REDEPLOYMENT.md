# NFT Redeployment Plan (Immutable Wiring)

## Problem Statement

The v3 claim NFT contract (`PoidhClaimNFT`) is **fully immutable** and has no owner or wiring
function. This means:

- Upgrading/migrating to a new POIDH bounty contract always requires a new NFT contract.
- Emergency responses cannot “rewire” mint authority; they require redeploying.

## Recommended Path: Redeploy a New Claim NFT for v3

Because there is no owner key to rewire mint authority, the practical option is:

1) deploy a new `PoidhClaimNFT` contract (new collection address)
2) deploy `PoidhV3` pointing at the new NFT
3) update the UI/indexer to the new addresses

This repository’s deploy scripts already follow this pattern:
- `script/Deploy.s.sol` (or `script/deploy/*.s.sol`)

## Product / UX Implications

- **v2 claim NFTs become “limited”**: the old collection can’t be wired to a new POIDH contract.
- v3 claim NFTs will live in a *new collection address*, even if name/symbol are similar.
- The frontend/indexer should treat v2 and v3 claim NFTs as distinct collections.

## Communications Guidance (Suggested)

- Announce that v2 claim NFTs are final/limited and that v3 uses a new claim NFT contract.
- Provide both collection addresses and clearly label them by version/network.

## Key Management Requirement

The NFT has no owner. Secure the deployer key and treasury key; document signer set + threshold
if treasury is a multisig.
