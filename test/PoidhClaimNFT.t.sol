// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {PoidhClaimNFT} from "../src/PoidhClaimNFT.sol";

contract DummyPoidh {}

contract PoidhClaimNFTTest is Test {
  PoidhClaimNFT nft;
  address poidh;

  function setUp() public {
    poidh = address(new DummyPoidh());
    nft = new PoidhClaimNFT("poidh claims v3", "POIDH3", poidh);
  }

  function test_constructor_reverts_zero_address() public {
    vm.expectRevert(PoidhClaimNFT.InvalidPoidhAddress.selector);
    new PoidhClaimNFT("poidh claims v3", "POIDH3", address(0));
  }

  function test_mintToEscrow_onlyPoidh() public {
    vm.expectRevert(PoidhClaimNFT.NotPoidh.selector);
    nft.mintToEscrow(1, "ipfs://x");
  }

  function test_mintToEscrow_mints_to_poidh() public {
    vm.prank(poidh);
    nft.mintToEscrow(1, "ipfs://x");

    assertEq(nft.ownerOf(1), poidh);
    assertEq(nft.tokenURI(1), "ipfs://x");
  }
}
