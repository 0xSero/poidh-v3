// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {Deploy} from "../script/Deploy.s.sol";
import {PoidhV3} from "../src/PoidhV3.sol";
import {PoidhClaimNFT} from "../src/PoidhClaimNFT.sol";

contract DeployScriptTest is Test {
  struct DeploymentInfo {
    address nft;
    address poidh;
    address treasury;
    uint256 startClaimIndex;
    uint256 minBounty;
    uint256 minContribution;
  }

  uint256 private constant MIN_BOUNTY = 0.002 ether;
  uint256 private constant MIN_CONTRIBUTION = 0.000_02 ether;
  uint256 private constant DEPLOYER_PK = 0xA11CE;

  function test_run_deploys_and_wires_contracts() public {
    address treasury = makeAddr("treasury");

    vm.setEnv("POIDH_TREASURY", vm.toString(treasury));
    vm.setEnv("POIDH_START_CLAIM_INDEX", "1");
    vm.setEnv("POIDH_MIN_BOUNTY_AMOUNT", vm.toString(MIN_BOUNTY));
    vm.setEnv("POIDH_MIN_CONTRIBUTION", vm.toString(MIN_CONTRIBUTION));
    vm.setEnv("DEPLOYER_PK", vm.toString(DEPLOYER_PK));
    vm.deal(vm.addr(DEPLOYER_PK), 100 ether);

    vm.recordLogs();
    Deploy d = new Deploy();
    d.run();

    DeploymentInfo memory info = _findDeployment(vm.getRecordedLogs());

    assertTrue(info.nft != address(0));
    assertTrue(info.poidh != address(0));

    PoidhClaimNFT nft = PoidhClaimNFT(info.nft);
    PoidhV3 poidh = PoidhV3(payable(info.poidh));

    assertEq(nft.poidh(), info.poidh);
    assertEq(poidh.treasury(), treasury);
    assertEq(info.treasury, treasury);
    assertEq(address(poidh.poidhNft()), info.nft);
    assertEq(poidh.claimCounter(), 1);
    assertEq(info.startClaimIndex, 1);
    assertEq(poidh.MIN_BOUNTY_AMOUNT(), MIN_BOUNTY);
    assertEq(poidh.MIN_CONTRIBUTION(), MIN_CONTRIBUTION);
    assertEq(info.minBounty, MIN_BOUNTY);
    assertEq(info.minContribution, MIN_CONTRIBUTION);
  }

  function _findDeployment(Vm.Log[] memory logs) internal pure returns (DeploymentInfo memory info) {
    bytes32 sig = keccak256("Deployment(address,address,address,uint256,uint256,uint256)");

    for (uint256 i = 0; i < logs.length; i++) {
      if (logs[i].topics.length == 3 && logs[i].topics[0] == sig) {
        // forge-lint: disable-next-line(unsafe-typecast)
        info.poidh = address(uint160(uint256(logs[i].topics[1])));
        // forge-lint: disable-next-line(unsafe-typecast)
        info.nft = address(uint160(uint256(logs[i].topics[2])));
        (info.treasury, info.startClaimIndex, info.minBounty, info.minContribution) =
          abi.decode(logs[i].data, (address, uint256, uint256, uint256));
        break;
      }
    }
  }
}
