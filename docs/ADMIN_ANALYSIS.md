# POIDH Admin Powers Analysis: v2 vs v3

This document provides a complete audit of all administrative/owner functionality in both v2 and v3 contracts.

---

## Executive Summary

| Version | Contract | Admin Functions | Admin Power Level |
|---------|----------|-----------------|-------------------|
| **v2** | PoidhV2.sol | **0** | None |
| **v2** | PoidhV2Nft.sol | **1** (`setPoidhContract`) | Minimal |
| **v3** | PoidhV3.sol | **0** | None |
| **v3** | PoidhClaimNFT.sol | **0** | None |

**V3 is fully immutable** - there is no owner and no admin wiring function. The claim NFT is
configured at deployment and cannot be changed afterward.

---

## V2 Contracts (Source: github.com/picsoritdidnthappen/poidh-contracts)

### PoidhV2.sol - Main Bounty Contract

**Imports:**
```solidity
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';
```

**Admin Analysis:**
| Feature | Present | Notes |
|---------|---------|-------|
| `Ownable` import | ❌ No | Not imported |
| `Pausable` import | ❌ No | Not imported |
| `onlyOwner` modifier | ❌ No | Does not exist |
| `pause()` / `unpause()` | ❌ No | Does not exist |
| Emergency withdraw | ❌ No | Does not exist |
| Mutable treasury | ❌ No | `address public immutable treasury` |
| Mutable fee | ❌ No | Hardcoded `(bountyAmount * 25) / 1000` (2.5%) |
| Owner state variable | ❌ No | Does not exist |

**Conclusion: PoidhV2.sol has ZERO admin powers.**

---

### PoidhV2Nft.sol - NFT Contract

**Imports:**
```solidity
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol';
```

**Note:** Does NOT import `Ownable` - uses a custom authority pattern instead.

**Admin Analysis:**
| Feature | Present | Notes |
|---------|---------|-------|
| `Ownable` import | ❌ No | Uses custom `poidhV2Authority` instead |
| `poidhV2Authority` | ✅ Yes | `address public immutable poidhV2Authority` |
| Admin function | ✅ Yes | `setPoidhContract(address, bool)` |

**The ONLY admin function:**
```solidity
function setPoidhContract(address _poidhContract, bool _hasPermission) external {
    require(msg.sender == poidhV2Authority, 'only poidhV2Authority can set poidh contracts');
    poidhContracts[_poidhContract] = _hasPermission;
    setApprovalForAll(_poidhContract, _hasPermission);
}
```

**What it does:**
- Allows/disallows contracts from minting claim NFTs
- Sets approval for the contract to transfer NFTs

**What it CANNOT do:**
- Cannot steal user funds
- Cannot pause the protocol
- Cannot change fees
- Cannot change treasury
- Cannot modify existing bounties/claims

**Risk:** If `poidhV2Authority` is compromised, attacker could:
1. Disable minting (griefing) by setting `poidhContracts[poidhV2] = false`
2. Enable a malicious contract to mint fake claim NFTs

---

## V3 Contracts (This Repository)

### PoidhV3.sol - Main Bounty Contract

**Imports:**
```solidity
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IPoidhClaimNFT} from "./interfaces/IPoidhClaimNFT.sol";
```

**Admin Analysis:**
| Feature | Present | Notes |
|---------|---------|-------|
| `Ownable*` inheritance | ❌ No | No owner/admin in `PoidhV3` |
| `pause()` / `unpause()` | ❌ No | Removed |
| Emergency withdraw | ❌ No | Does not exist |
| Mutable treasury | ❌ No | `address public immutable treasury` |
| Mutable fee | ❌ No | `uint256 public constant FEE_BPS = 250` |
| Mutable votingPeriod | ❌ No | No setter; voting period is fixed in this implementation |

**Conclusion: PoidhV3.sol has ZERO admin powers and no owner.**

---

### PoidhClaimNFT.sol - NFT Contract

**Imports:**
```solidity
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {IPoidhClaimNFT} from "./interfaces/IPoidhClaimNFT.sol";
```

**Admin Analysis:**
| Feature | Present | Notes |
|---------|---------|-------|
| `Ownable*` inheritance | ❌ No | No owner/admin |
| Owner-only functions | ❌ No | None |

**Immutable wiring (constructor-only):**
- `poidh` is an immutable address set at deployment.
- There is **no** `setPoidh()` and no ownership surface.

**What it CANNOT do:**
- Cannot steal user funds (funds are in PoidhV3, not NFT contract)
- Cannot pause the protocol
- Cannot change fees
- Cannot change treasury
- Cannot modify existing bounties/claims
- Cannot burn or transfer user NFTs

**Risk:** If deployment is misconfigured, there is no admin lever to fix it.
Recovery requires deploying a new NFT contract (and PoidhV3) and updating the UI/indexer.

---

## Comparison Matrix

| Capability | v2 PoidhV2 | v2 PoidhV2Nft | v3 PoidhV3 | v3 PoidhClaimNFT |
|------------|------------|---------------|------------|------------------|
| Steal user funds | ❌ | ❌ | ❌ | ❌ |
| Pause protocol | ❌ | ❌ | ❌ | ❌ |
| Change fee % | ❌ | ❌ | ❌ | ❌ |
| Change treasury | ❌ | ❌ | ❌ | ❌ |
| Block new mints | ❌ | ✅ | ❌ | ❌ |
| Enable rogue minter | ❌ | ✅ | ❌ | ❌ |
| Upgrade contract | ❌ | ❌ | ❌ | ❌ |

---

## Recommendations for V3

### Deployment determinism (required)

- Compute the PoidhV3 address before deploying `PoidhClaimNFT`.
- Deploy the NFT with the immutable `poidh` address, then deploy PoidhV3.
- Verify `PoidhClaimNFT.poidh()` matches the deployed PoidhV3 address.

### Operational implication

- There is **no** owner key to recover or use for migration.
- Any migration requires **deploying a new NFT + PoidhV3 pair** and updating the UI/indexer.
- Migration notes and comms guidance:
  - `docs/migrations/NFT_REDEPLOYMENT.md`

### Status: Fully Immutable (Implemented)

This repo’s `PoidhV3` and `PoidhClaimNFT` have no owner/admin surface.

---

## Summary

**V2 was more trustless than the security report suggested.** It had:
- No pause functionality
- No admin withdraw
- Only a single `setPoidhContract()` function on the NFT

**V3 matches V2's minimal admin model:**
- No pause functionality (removed)
- No admin withdraw
- No admin wiring or owner surface on the NFT
- `PoidhV3.sol` has no owner/admin surface

**In v3 there are no admin powers at all.** Claim NFT minting is wired once at deployment and is immutable thereafter.
