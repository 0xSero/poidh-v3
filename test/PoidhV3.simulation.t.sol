// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {PoidhDeployHelper} from "./utils/PoidhDeployHelper.sol";
import {PoidhV3} from "../src/PoidhV3.sol";
import {PoidhClaimNFT} from "../src/PoidhClaimNFT.sol";

contract PoidhV3SimulationTest is PoidhDeployHelper {
  PoidhV3 poidh;
  PoidhClaimNFT nft;

  address treasury;
  address issuer1;
  address issuer2;
  address claimant1;
  address claimant2;
  address contributor1;
  address contributor2;

  function setUp() public {
    vm.txGasPrice(0);

    treasury = makeAddr("treasury");
    issuer1 = makeAddr("issuer1");
    issuer2 = makeAddr("issuer2");
    claimant1 = makeAddr("claimant1");
    claimant2 = makeAddr("claimant2");
    contributor1 = makeAddr("contributor1");
    contributor2 = makeAddr("contributor2");

    (poidh, nft) = deployPoidh(treasury, 1);

    vm.deal(issuer1, 50 ether);
    vm.deal(issuer2, 50 ether);
    vm.deal(claimant1, 50 ether);
    vm.deal(claimant2, 50 ether);
    vm.deal(contributor1, 50 ether);
    vm.deal(contributor2, 50 ether);
  }

  function test_simulation_realistic_lifecycle() public {
    uint256 minContrib = poidh.MIN_CONTRIBUTION();

    // Open bounty with two contributors and a vote.
    uint256 openBountyId = poidh.bountyCounter();
    vm.prank(issuer1, issuer1);
    poidh.createOpenBounty{value: 5 ether}("open-1", "desc");

    vm.prank(contributor1);
    poidh.joinOpenBounty{value: minContrib * 5}(openBountyId);
    vm.prank(contributor2);
    poidh.joinOpenBounty{value: minContrib * 3}(openBountyId);

    uint256 claimId1 = poidh.claimCounter();
    vm.prank(claimant1);
    poidh.createClaim(openBountyId, "claim-1", "desc", "ipfs://claim1");

    vm.prank(issuer1, issuer1);
    poidh.submitClaimForVote(openBountyId, claimId1);

    vm.prank(contributor1);
    poidh.voteClaim(openBountyId, true);
    vm.prank(contributor2);
    poidh.voteClaim(openBountyId, false);

    vm.warp(block.timestamp + poidh.votingPeriod() + 1);
    poidh.resolveVote(openBountyId);

    uint256 yes = 5 ether + (minContrib * 5);
    uint256 no = minContrib * 3;
    bool passed = yes > ((yes + no) / 2);

    if (passed) {
      assertEq(nft.ownerOf(claimId1), issuer1);
      assertTrue(poidh.pendingWithdrawals(claimant1) > 0);
    } else {
      assertEq(nft.ownerOf(claimId1), address(poidh));
    }

    // Solo bounty happy path.
    uint256 soloBountyId = poidh.bountyCounter();
    vm.prank(issuer2, issuer2);
    poidh.createSoloBounty{value: 2 ether}("solo-1", "desc");

    uint256 claimId2 = poidh.claimCounter();
    vm.prank(claimant2);
    poidh.createClaim(soloBountyId, "claim-2", "desc", "ipfs://claim2");

    vm.prank(issuer2, issuer2);
    poidh.acceptClaim(soloBountyId, claimId2);

    assertEq(nft.ownerOf(claimId2), issuer2);
    assertTrue(poidh.pendingWithdrawals(claimant2) > 0);

    // Open bounty cancellation + refunds.
    uint256 cancelBountyId = poidh.bountyCounter();
    vm.prank(issuer1, issuer1);
    poidh.createOpenBounty{value: 1 ether}("open-2", "desc");

    vm.prank(contributor1);
    poidh.joinOpenBounty{value: minContrib}(cancelBountyId);

    vm.prank(issuer1, issuer1);
    poidh.cancelOpenBounty(cancelBountyId);

    vm.prank(contributor1);
    poidh.claimRefundFromCancelledOpenBounty(cancelBountyId);

    _withdrawIfAny(claimant1);
    _withdrawIfAny(claimant2);
    _withdrawIfAny(contributor1);
    _withdrawIfAny(issuer1);
    _withdrawIfAny(issuer2);
  }

  function _withdrawIfAny(address who) internal {
    uint256 pending = poidh.pendingWithdrawals(who);
    if (pending == 0) return;
    vm.prank(who);
    poidh.withdraw();
  }
}
