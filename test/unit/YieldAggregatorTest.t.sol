// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {YieldAggregator} from "src/YieldAggregator.sol";
import {StrategyManager} from "src/StrategyManager.sol";
import {CompoundV3Adapter} from "src/adapters/CompoundV3Adapter.sol";
// import {MockERC20} from "./mocks/MockERC20.sol";
// import {MockAavePool} from "./mocks/MockAavePool.sol";
// import {MockCompound} from "./mocks/MockCompound.sol";

contract YieldAggregatorTest is Test {
    event AdapterAdded(string indexed protocolName, address indexed adapterAddress);

    YieldAggregator yieldAggregator;
    StrategyManager strategyManager;
    CompoundV3Adapter compoundV3Adapter;
    uint256 ethSepoliaFork;

    address public OWNER = makeAddr("owner");

    function setUp() public {
        strategyManager = new StrategyManager();
        vm.prank(OWNER);
        yieldAggregator = new YieldAggregator(address(strategyManager));
    }

    function testAddAdapterRevertsIfNotOwner() external {
        // ARRANGE
        address NON_OWNER = makeAddr("non_owner");

        // ACT & ASSERT
        vm.expectRevert();
        vm.prank(NON_OWNER);
        yieldAggregator.addAdapter("compound", NON_OWNER);
    }

    function testAddAdapterRevertsIfZeroAddress() external {
        // ARRANGE
        address zeroAddress = address(0);

        // ACT & ASSERT
        vm.expectRevert(YieldAggregator.YieldAggregator__InvalidAdapterAddress.selector);
        vm.prank(OWNER);
        yieldAggregator.addAdapter("compound", zeroAddress);
    }

    function testAddCompoundAdapterIsSuccessful() external {
        // ARRANGE
        address COMPOUND_ETH_SEPOLIA_USDC_ADDRESS = 0xAec1F48e02Cfb822Be958B68C7957156EB3F0b6e;
        compoundV3Adapter = new CompoundV3Adapter(COMPOUND_ETH_SEPOLIA_USDC_ADDRESS);

        // ACT
        vm.expectEmit(true, true, false, false);
        emit AdapterAdded("compoundV3_USDC", address(compoundV3Adapter));
        vm.prank(OWNER);
        yieldAggregator.addAdapter("compoundV3_USDC", address(compoundV3Adapter));
    }

    modifier addCompoundETHSepoliaUSDCAdapter() {
        address COMPOUND_ETH_SEPOLIA_USDC_ADDRESS = 0xAec1F48e02Cfb822Be958B68C7957156EB3F0b6e;
        compoundV3Adapter = new CompoundV3Adapter(COMPOUND_ETH_SEPOLIA_USDC_ADDRESS);
        vm.prank(OWNER);
        yieldAggregator.addAdapter("compoundV3_USDC", address(compoundV3Adapter));
        _;
    }

    function testCompoundAdapterDeploysSuccessfully() external addCompoundETHSepoliaUSDCAdapter {
        // ARRANGE
        address ETH_SEPOLIA_USDC_ADDRESS = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;
        address COMPOUND_ETH_SEPOLIA_USDC_ADDRESS = 0xAec1F48e02Cfb822Be958B68C7957156EB3F0b6e;
        ethSepoliaFork = vm.createSelectFork("sepolia_eth");

        // ACT
        vm.prank(OWNER);
        compoundV3Adapter = new CompoundV3Adapter(COMPOUND_ETH_SEPOLIA_USDC_ADDRESS);
        // vm.prank(OWNER);
        // yieldAggregator.invest(ETH_SEPOLIA_USDC_ADDRESS, 1, "compoundV3_USDC");

        // ASSERT
    }
}
