// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {YieldAggregator} from "src/YieldAggregator.sol";
import {CompoundV3Adapter} from "src/adapters/CompoundV3Adapter.sol";
import {AaveV3Adapter} from "src/adapters/AaveV3Adapter.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IComet} from "src/interfaces/IComet.sol";

// import {MockERC20} from "./mocks/MockERC20.sol";
// import {MockAavePool} from "./mocks/MockAavePool.sol";
// import {MockCompound} from "./mocks/MockCompound.sol";

contract YieldAggregatorTest is Test {
    using SafeERC20 for IERC20;

    event AdapterAdded(string indexed protocolName, address indexed adapterAddress);

    YieldAggregator yieldAggregator;
    CompoundV3Adapter compoundV3Adapter;
    uint256 positionIndex;
    uint256 ethSepoliaFork;

    address public OWNER = makeAddr("owner");
    uint256 OWNER_USDC_BALANCE = 10_000e6;
    uint256 OWNER_ETH_BALANCE = 1 ether;

    function setUp() public {
        vm.prank(OWNER);
        yieldAggregator = new YieldAggregator();
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

    function testOwnerCanInvestIntoASpecificProtocolSuccesfully__Compound() external {
        // ARRANGE
        uint256 INVESTED_AMOUNT = 1e6;
        //@notice This is the USDC address on Ethereum Sepolia network
        address ETH_SEPOLIA_USDC_ADDRESS = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;
        //@notice This is the Compound V3 Comet contract address for USDC on Ethereum Sepolia network
        address COMPOUND_ETH_SEPOLIA_USDC_ADDRESS = 0xAec1F48e02Cfb822Be958B68C7957156EB3F0b6e;
        //@notice create a fork of Ethereum Sepolia network
        ethSepoliaFork = vm.createSelectFork("sepolia_eth");

        // ACT
        //@notice This funds the owner with some ETH to pay for gas fees
        vm.deal(OWNER, OWNER_ETH_BALANCE);
        //@notice Foundry cheatcode to send tokens to an address
        deal(ETH_SEPOLIA_USDC_ADDRESS, OWNER, OWNER_USDC_BALANCE);
        uint256 OWNER_USDC_BALANCE_BEFORE_INVESTING = IERC20(ETH_SEPOLIA_USDC_ADDRESS).balanceOf(OWNER);
        //@notice for the test to work, I have to redeploy the yield aggregator contract since the createSelectFork changes the network context
        vm.prank(OWNER);
        yieldAggregator = new YieldAggregator();
        compoundV3Adapter = new CompoundV3Adapter(COMPOUND_ETH_SEPOLIA_USDC_ADDRESS);
        vm.prank(OWNER);
        yieldAggregator.addAdapter("compoundV3_USDC", address(compoundV3Adapter));

        vm.prank(OWNER);
        IERC20(ETH_SEPOLIA_USDC_ADDRESS).forceApprove(address(yieldAggregator), OWNER_USDC_BALANCE); // note: owner has to approve YieldAggregator to spend her USDC tokens
        vm.prank(OWNER);
        positionIndex = yieldAggregator.invest(ETH_SEPOLIA_USDC_ADDRESS, INVESTED_AMOUNT, "compoundV3_USDC");
        uint256 OWNER_USDC_BALANCE_AFTER_INVESTING = IERC20(ETH_SEPOLIA_USDC_ADDRESS).balanceOf(OWNER);

        // ASSERT
        assertEq(OWNER_USDC_BALANCE_BEFORE_INVESTING - OWNER_USDC_BALANCE_AFTER_INVESTING, INVESTED_AMOUNT);
        assertEq(positionIndex, 0);
    }

    function testInvestRevertsIfCallerHasInsuffucientBalance() external {
        // ARRANGE
        uint256 INVESTED_AMOUNT = 1e6;
        //@notice This is the USDC address on Ethereum Sepolia network
        address ETH_SEPOLIA_USDC_ADDRESS = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;
        //@notice This is the Compound V3 Comet contract address for USDC on Ethereum Sepolia network
        address COMPOUND_ETH_SEPOLIA_USDC_ADDRESS = 0xAec1F48e02Cfb822Be958B68C7957156EB3F0b6e;
        //@notice create a fork of Ethereum Sepolia network
        ethSepoliaFork = vm.createSelectFork("sepolia_eth");

        // ACT
        //@notice This funds the owner with some ETH to pay for gas fees
        vm.deal(OWNER, OWNER_ETH_BALANCE);
        //@notice Foundry cheatcode to send tokens to an address
        deal(ETH_SEPOLIA_USDC_ADDRESS, OWNER, OWNER_USDC_BALANCE);
        //@notice for the test to work, I have to redeploy the yield aggregator contract since the createSelectFork changes the network context
        vm.prank(OWNER);
        yieldAggregator = new YieldAggregator();
        compoundV3Adapter = new CompoundV3Adapter(COMPOUND_ETH_SEPOLIA_USDC_ADDRESS);
        vm.prank(OWNER);
        yieldAggregator.addAdapter("compoundV3_USDC", address(compoundV3Adapter));

        vm.prank(OWNER);
        IERC20(ETH_SEPOLIA_USDC_ADDRESS).forceApprove(address(yieldAggregator), OWNER_USDC_BALANCE); // note: owner has to approve YieldAggregator to spend her USDC tokens
        vm.prank(OWNER);
        vm.expectRevert(YieldAggregator.YieldAggregator__InsufficientBalance.selector);
        yieldAggregator.invest(ETH_SEPOLIA_USDC_ADDRESS, INVESTED_AMOUNT + OWNER_USDC_BALANCE, "compoundV3_USDC");
    }

    function testInvestRevertsIfInvalidTokenAddress() external {
        // ARRANGE
        uint256 INVESTED_AMOUNT = 1e6;
        //@notice This is the USDC address on Ethereum Sepolia network
        address ETH_SEPOLIA_USDC_ADDRESS = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;
        //@notice This is the Compound V3 Comet contract address for USDC on Ethereum Sepolia network
        address COMPOUND_ETH_SEPOLIA_USDC_ADDRESS = 0xAec1F48e02Cfb822Be958B68C7957156EB3F0b6e;
        //@notice create a fork of Ethereum Sepolia network
        ethSepoliaFork = vm.createSelectFork("sepolia_eth");

        // ACT
        //@notice This funds the owner with some ETH to pay for gas fees
        vm.deal(OWNER, OWNER_ETH_BALANCE);
        //@notice Foundry cheatcode to send tokens to an address
        deal(ETH_SEPOLIA_USDC_ADDRESS, OWNER, OWNER_USDC_BALANCE);
        //@notice for the test to work, I have to redeploy the yield aggregator contract since the createSelectFork changes the network context
        vm.prank(OWNER);
        yieldAggregator = new YieldAggregator();
        compoundV3Adapter = new CompoundV3Adapter(COMPOUND_ETH_SEPOLIA_USDC_ADDRESS);
        vm.prank(OWNER);
        yieldAggregator.addAdapter("compoundV3_USDC", address(compoundV3Adapter));

        vm.prank(OWNER);
        IERC20(ETH_SEPOLIA_USDC_ADDRESS).forceApprove(address(yieldAggregator), OWNER_USDC_BALANCE); // note: owner has to approve YieldAggregator to spend her USDC tokens
        vm.prank(OWNER);
        vm.expectRevert(YieldAggregator.YieldAggregator__InvalidToken.selector);
        yieldAggregator.invest(address(0), INVESTED_AMOUNT, "compoundV3_USDC");
    }

    function testInvestRevertsIfZeroAmount() external {
        // ARRANGE
        uint256 ZERO_AMOUNT = 0;
        //@notice This is the USDC address on Ethereum Sepolia network
        address ETH_SEPOLIA_USDC_ADDRESS = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;
        //@notice This is the Compound V3 Comet contract address for USDC on Ethereum Sepolia network
        address COMPOUND_ETH_SEPOLIA_USDC_ADDRESS = 0xAec1F48e02Cfb822Be958B68C7957156EB3F0b6e;
        //@notice create a fork of Ethereum Sepolia network
        ethSepoliaFork = vm.createSelectFork("sepolia_eth");

        // ACT
        //@notice This funds the owner with some ETH to pay for gas fees
        vm.deal(OWNER, OWNER_ETH_BALANCE);
        //@notice Foundry cheatcode to send USDC tokens to an address
        deal(ETH_SEPOLIA_USDC_ADDRESS, OWNER, OWNER_USDC_BALANCE);
        //@notice for the test to work, I have to redeploy the yield aggregator contract since the createSelectFork changes the network context
        vm.prank(OWNER);
        yieldAggregator = new YieldAggregator();
        compoundV3Adapter = new CompoundV3Adapter(COMPOUND_ETH_SEPOLIA_USDC_ADDRESS);
        vm.prank(OWNER);
        yieldAggregator.addAdapter("compoundV3_USDC", address(compoundV3Adapter));

        vm.prank(OWNER);
        IERC20(ETH_SEPOLIA_USDC_ADDRESS).forceApprove(address(yieldAggregator), OWNER_USDC_BALANCE); // note: owner has to approve YieldAggregator to spend her USDC tokens
        vm.prank(OWNER);
        vm.expectRevert(YieldAggregator.YieldAggregator__InvalidAmount.selector);
        yieldAggregator.invest(ETH_SEPOLIA_USDC_ADDRESS, ZERO_AMOUNT, "compoundV3_USDC");
    }

    modifier investedIntoASpecificProtocol() {
        // ARRANGE
        uint256 INVESTED_AMOUNT = 1e6;
        //@notice This is the USDC address on Ethereum Sepolia network
        address ETH_SEPOLIA_USDC_ADDRESS = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;
        //@notice This is the Compound V3 Comet contract address for USDC on Ethereum Sepolia network
        address COMPOUND_ETH_SEPOLIA_USDC_ADDRESS = 0xAec1F48e02Cfb822Be958B68C7957156EB3F0b6e;
        //@notice create a fork of Ethereum Sepolia network
        ethSepoliaFork = vm.createSelectFork("sepolia_eth");

        // ACT
        //@notice This funds the owner with some ETH to pay for gas fees
        vm.deal(OWNER, OWNER_ETH_BALANCE);
        //@notice Foundry cheatcode to send tokens to an address
        deal(ETH_SEPOLIA_USDC_ADDRESS, OWNER, OWNER_USDC_BALANCE);
        //@notice for the test to work, I have to redeploy the yield aggregator contract since the createSelectFork changes the network context
        vm.prank(OWNER);
        yieldAggregator = new YieldAggregator();
        compoundV3Adapter = new CompoundV3Adapter(COMPOUND_ETH_SEPOLIA_USDC_ADDRESS);
        vm.prank(OWNER);
        yieldAggregator.addAdapter("compoundV3_USDC", address(compoundV3Adapter));

        vm.prank(OWNER);
        IERC20(ETH_SEPOLIA_USDC_ADDRESS).forceApprove(address(yieldAggregator), OWNER_USDC_BALANCE); // note: owner has to approve YieldAggregator to spend her USDC tokens
        vm.prank(OWNER);
        positionIndex = yieldAggregator.invest(ETH_SEPOLIA_USDC_ADDRESS, INVESTED_AMOUNT, "compoundV3_USDC");
        _;
    }

    function testGetUserPositions() external investedIntoASpecificProtocol {
        // ACT
        yieldAggregator.getUserPositions(OWNER);
        yieldAggregator.getUserPositionCount(OWNER);
        yieldAggregator.getUserPositionByIndex(OWNER, positionIndex);

        // ASSERT
        assertEq(positionIndex, 0);
    }

    /// @notice Test that owner can withdraw successfully and receives funds
    function testOwnerCanWithdrawFromASpecificProtocolSuccessfully__Compound() external investedIntoASpecificProtocol {
        // ARRANGE
        address ETH_SEPOLIA_USDC_ADDRESS = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;

        uint256 ownerBalanceBefore = IERC20(ETH_SEPOLIA_USDC_ADDRESS).balanceOf(OWNER);
        uint256 positionCountBefore = yieldAggregator.getUserPositionCount(OWNER);

        // ACT
        vm.prank(OWNER);
        yieldAggregator.withdraw(positionIndex);

        // ASSERT
        uint256 ownerBalanceAfter = IERC20(ETH_SEPOLIA_USDC_ADDRESS).balanceOf(OWNER);
        uint256 positionCountAfter = yieldAggregator.getUserPositionCount(OWNER);

        // Verify balance increased
        assertGt(ownerBalanceAfter, ownerBalanceBefore, "Owner balance should increase after withdrawal");

        // Verify position was removed
        assertEq(positionCountAfter, positionCountBefore - 1, "Position count should decrease by 1");
        assertEq(positionCountAfter, 0, "Should have 0 positions after withdrawal");
    }

    // function testInterestAccruesOnInvestmentOvertimeOnMainnet() external {
    //     vm.warp(block.timestamp + 365 days); // simulate time passage to accrue some interest, this interest accrual doesn't work on testnet only on mainnet
    // }
}
