// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {YieldAggregator} from "src/YieldAggregator.sol";
import {StrategyManager} from "src/StrategyManager.sol";
// import {MockERC20} from "./mocks/MockERC20.sol";
// import {MockAavePool} from "./mocks/MockAavePool.sol";
// import {MockCompound} from "./mocks/MockCompound.sol";

contract YieldAggregatorTest is Test {
    YieldAggregator yieldAggregator;
    StrategyManager strategyManager;

    function setUp() public {}
}
