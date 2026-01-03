// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {DeployBaseScript} from "../DeployBase.s.sol";

contract DeployBase is DeployBaseScript {
    address constant TREASURY = 0xdA0fc970CBa6f541ba39276A46E1118aCeBa3916;

    function run() external {
        DeployConfig memory cfg = _loadCommonConfig();
        cfg.treasury = TREASURY;
        cfg.minBountyAmount = 0.001 ether;
        cfg.minContribution = 0.000_01 ether;
        _deploy(cfg);
    }
}
