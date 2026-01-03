// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {DeployBaseScript} from "../DeployBase.s.sol";

contract DeployBaseSepolia is DeployBaseScript {
  function run() external {
    DeployConfig memory cfg = _loadCommonConfig();
    cfg.minBountyAmount = 0.001 ether;
    cfg.minContribution = 0.000_01 ether;
    _deploy(cfg);
  }
}
