// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {DeployBaseScript} from "../DeployBase.s.sol";

contract DeployArbitrum is DeployBaseScript {
  address constant TREASURY = 0x1a706a29822921d6c641E472bD33CF945A13FEF9;

  function run() external {
    DeployConfig memory cfg = _loadCommonConfig();
    cfg.treasury = TREASURY;
    cfg.minBountyAmount = 0.001 ether;
    cfg.minContribution = 0.000_01 ether;
    _deploy(cfg);
  }
}
