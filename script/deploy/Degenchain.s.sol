// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {DeployBaseScript} from "../DeployBase.s.sol";

contract DeployDegenchain is DeployBaseScript {
  address constant TREASURY = 0x574da84cB149f9424FcF3dd21EBeef1E160cD2bF;

  function run() external {
    DeployConfig memory cfg = _loadCommonConfig();
    cfg.treasury = TREASURY;
    cfg.minBountyAmount = 1 ether;
    cfg.minContribution = 1 ether;
    _deploy(cfg);
  }
}
