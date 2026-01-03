// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {PoidhV3} from "../../src/PoidhV3.sol";
import {PoidhClaimNFT} from "../../src/PoidhClaimNFT.sol";

abstract contract PoidhDeployHelper is Test {
  uint256 internal constant DEFAULT_MIN_BOUNTY_AMOUNT = 0.001 ether;
  uint256 internal constant DEFAULT_MIN_CONTRIBUTION = 0.000_01 ether;

  function deployPoidh(address treasury, uint256 startClaimIndex)
    internal
    returns (PoidhV3 poidh, PoidhClaimNFT nft)
  {
    return
      deployPoidhWithMins(
        treasury,
        startClaimIndex,
        DEFAULT_MIN_BOUNTY_AMOUNT,
        DEFAULT_MIN_CONTRIBUTION
      );
  }

  function deployPoidhWithMins(
    address treasury,
    uint256 startClaimIndex,
    uint256 minBountyAmount,
    uint256 minContribution
  ) internal returns (PoidhV3 poidh, PoidhClaimNFT nft) {
    uint256 nonce = vm.getNonce(address(this));
    address predictedPoidh = vm.computeCreateAddress(address(this), nonce + 1);

    nft = new PoidhClaimNFT("poidh claims v3", "POIDH3", predictedPoidh);
    poidh = new PoidhV3(address(nft), treasury, startClaimIndex, minBountyAmount, minContribution);
  }
}
