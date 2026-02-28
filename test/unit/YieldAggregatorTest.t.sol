// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {YieldAggregator} from "src/YieldAggregator.sol";
import {CompoundV3Adapter} from "src/adapters/CompoundV3Adapter.sol";
import {AaveV3Adapter} from "src/adapters/AaveV3Adapter.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IComet} from "src/interfaces/IComet.sol";
import {SelfDestruct} from "test/utils/SelfDestruct.sol";

// import {MockERC20} from "./mocks/MockERC20.sol";
// import {MockAavePool} from "./mocks/MockAavePool.sol";
// import {MockCompound} from "./mocks/MockCompound.sol";

contract YieldAggregatorTest is Test {
    using SafeERC20 for IERC20;

    event AdapterAdded(string indexed protocolName, address indexed adapterAddress);

    YieldAggregator yieldAggregator;
    CompoundV3Adapter compoundV3Adapter;
    AaveV3Adapter aaveV3Adapter;
    uint256 positionIndex;
    uint256 ethSepoliaFork;

    address public OWNER = makeAddr("owner");
    uint256 OWNER_USDC_BALANCE = 10_000e6;
    uint256 OWNER_ETH_BALANCE = 1 ether;

    address public SECOND_USER = makeAddr("second_user");
    uint256 SECOND_USER_USDC_BALANCE = 100_000e6;
    uint256 SECOND_USER_ETH_BALANCE = 10 ether;

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
        uint256 INVESTED_AMOUNT = 1000e6;
        //@notice This is the USDC address on Ethereum Mainnet network
        address ETH_MAINNET_USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        //@notice This is the Compound V3 Comet contract address for USDC on Ethereum Mainnet network
        address COMPOUND_ETH_MAINNET_USDC_ADDRESS = 0xc3d688B66703497DAA19211EEdff47f25384cdc3;
        //@notice create a fork of Ethereum Mainnet network
        ethSepoliaFork = vm.createSelectFork("mainnet_eth");

        // ACT
        //@notice This funds the owner with some ETH to pay for gas fees
        vm.deal(OWNER, OWNER_ETH_BALANCE);
        //@notice Foundry cheatcode to send tokens to an address
        deal(ETH_MAINNET_USDC_ADDRESS, OWNER, OWNER_USDC_BALANCE);
        uint256 OWNER_USDC_BALANCE_BEFORE_INVESTING = IERC20(ETH_MAINNET_USDC_ADDRESS).balanceOf(OWNER);
        //@notice for the test to work, I have to redeploy the yield aggregator contract since the createSelectFork changes the network context
        vm.prank(OWNER);
        yieldAggregator = new YieldAggregator();
        compoundV3Adapter = new CompoundV3Adapter(COMPOUND_ETH_MAINNET_USDC_ADDRESS);
        vm.prank(OWNER);
        yieldAggregator.addAdapter("compoundV3_USDC", address(compoundV3Adapter));

        vm.prank(OWNER);
        IERC20(ETH_MAINNET_USDC_ADDRESS).forceApprove(address(yieldAggregator), OWNER_USDC_BALANCE); // note: owner has to approve YieldAggregator to spend her USDC tokens
        vm.prank(OWNER);
        positionIndex = yieldAggregator.invest(ETH_MAINNET_USDC_ADDRESS, INVESTED_AMOUNT, "compoundV3_USDC");
        uint256 OWNER_USDC_BALANCE_AFTER_INVESTING = IERC20(ETH_MAINNET_USDC_ADDRESS).balanceOf(OWNER);

        // ASSERT
        assertEq(OWNER_USDC_BALANCE_BEFORE_INVESTING - OWNER_USDC_BALANCE_AFTER_INVESTING, INVESTED_AMOUNT);
        assertEq(positionIndex, 0);
    }

    function testOwnerCanInvestIntoASpecificProtocolSuccesfully__Aave() external {
        // ARRANGE
        uint256 INVESTED_AMOUNT = 1000e6;
        //@notice This is the USDC address on Ethereum Sepolia network for aave
        address AAVE_ETH_MAINNET_USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        //@notice Aave V3 PoolAddressesProvider on Ethereum Sepolia
        address AAVE_POOL_ADDRESSES_PROVIDER = 0x2f39d218133AFaB8F2B819B1066c7E434Ad94E9e;
        //@notice create a fork of Ethereum Sepolia network
        ethSepoliaFork = vm.createSelectFork("mainnet_eth");

        // ACT
        //@notice This funds the owner with some ETH to pay for gas fees
        vm.deal(OWNER, OWNER_ETH_BALANCE);
        //@notice Foundry cheatcode to send tokens to an address
        deal(AAVE_ETH_MAINNET_USDC_ADDRESS, OWNER, OWNER_USDC_BALANCE);
        uint256 OWNER_USDC_BALANCE_BEFORE_INVESTING = IERC20(AAVE_ETH_MAINNET_USDC_ADDRESS).balanceOf(OWNER);
        //@notice for the test to work, I have to redeploy the yield aggregator contract since the createSelectFork changes the network context
        vm.prank(OWNER);
        yieldAggregator = new YieldAggregator();
        vm.prank(OWNER);
        aaveV3Adapter = new AaveV3Adapter(AAVE_POOL_ADDRESSES_PROVIDER);
        vm.prank(OWNER);
        yieldAggregator.addAdapter("aaveV3_USDC", address(aaveV3Adapter));

        vm.prank(OWNER);
        IERC20(AAVE_ETH_MAINNET_USDC_ADDRESS).forceApprove(address(yieldAggregator), OWNER_USDC_BALANCE); // note: owner has to approve YieldAggregator to spend her USDC tokens
        vm.prank(OWNER);
        positionIndex = yieldAggregator.invest(AAVE_ETH_MAINNET_USDC_ADDRESS, INVESTED_AMOUNT, "aaveV3_USDC");
        uint256 OWNER_USDC_BALANCE_AFTER_INVESTING = IERC20(AAVE_ETH_MAINNET_USDC_ADDRESS).balanceOf(OWNER);

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

    modifier investedIntoASpecificProtocol__Compound() {
        // ARRANGE
        uint256 INVESTED_AMOUNT = 1000e6;
        //@notice This is the USDC address on Ethereum Mainnet network
        address ETH_MAINNET_USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        //@notice This is the Compound V3 Comet contract address for USDC on Ethereum Mainnet network
        address COMPOUND_ETH_MAINNET_USDC_ADDRESS = 0xc3d688B66703497DAA19211EEdff47f25384cdc3;
        //@notice create a fork of Ethereum Mainnet network
        ethSepoliaFork = vm.createSelectFork("mainnet_eth");

        // ACT
        //@notice This funds the owner with some ETH to pay for gas fees
        vm.deal(OWNER, OWNER_ETH_BALANCE);
        //@notice Foundry cheatcode to send tokens to an address
        deal(ETH_MAINNET_USDC_ADDRESS, OWNER, OWNER_USDC_BALANCE);
        //@notice for the test to work, I have to redeploy the yield aggregator contract since the createSelectFork changes the network context
        vm.prank(OWNER);
        yieldAggregator = new YieldAggregator();
        compoundV3Adapter = new CompoundV3Adapter(COMPOUND_ETH_MAINNET_USDC_ADDRESS);
        vm.prank(OWNER);
        yieldAggregator.addAdapter("compoundV3_USDC", address(compoundV3Adapter));

        vm.prank(OWNER);
        IERC20(ETH_MAINNET_USDC_ADDRESS).forceApprove(address(yieldAggregator), OWNER_USDC_BALANCE); // note: owner has to approve YieldAggregator to spend her USDC tokens
        vm.prank(OWNER);
        positionIndex = yieldAggregator.invest(ETH_MAINNET_USDC_ADDRESS, INVESTED_AMOUNT, "compoundV3_USDC");
        _;
    }

    modifier investedIntoASpecificProtocol__Aave() {
        // ARRANGE
        uint256 INVESTED_AMOUNT = 1000e6;
        //@notice This is the USDC address on Ethereum Sepolia network for aave
        address AAVE_ETH_SEPOLI_USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        //@notice Aave V3 PoolAddressesProvider on Ethereum Sepolia
        address AAVE_POOL_ADDRESSES_PROVIDER = 0x2f39d218133AFaB8F2B819B1066c7E434Ad94E9e;
        //@notice create a fork of Ethereum Sepolia network
        ethSepoliaFork = vm.createSelectFork("mainnet_eth");

        // ACT
        //@notice This funds the owner with some ETH to pay for gas fees
        vm.deal(OWNER, OWNER_ETH_BALANCE);
        //@notice Foundry cheatcode to send tokens to an address
        deal(AAVE_ETH_SEPOLI_USDC_ADDRESS, OWNER, OWNER_USDC_BALANCE);
        //@notice for the test to work, I have to redeploy the yield aggregator contract since the createSelectFork changes the network context
        vm.prank(OWNER);
        yieldAggregator = new YieldAggregator();
        vm.prank(OWNER);
        aaveV3Adapter = new AaveV3Adapter(AAVE_POOL_ADDRESSES_PROVIDER);
        vm.prank(OWNER);
        yieldAggregator.addAdapter("aaveV3_USDC", address(aaveV3Adapter));

        vm.prank(OWNER);
        IERC20(AAVE_ETH_SEPOLI_USDC_ADDRESS).forceApprove(address(yieldAggregator), OWNER_USDC_BALANCE); // note: owner has to approve YieldAggregator to spend her USDC tokens
        vm.prank(OWNER);
        positionIndex = yieldAggregator.invest(AAVE_ETH_SEPOLI_USDC_ADDRESS, INVESTED_AMOUNT, "aaveV3_USDC");
        uint256 OWNER_USDC_BALANCE_AFTER_INVESTING = IERC20(AAVE_ETH_SEPOLI_USDC_ADDRESS).balanceOf(OWNER);
        _;
    }

    /// @notice Test that owner can withdraw successfully and receives funds from Compound
    function testOwnerCanWithdrawFromASpecificProtocolSuccessfully__Compound()
        external
        investedIntoASpecificProtocol__Compound
    {
        // ARRANGE
        address ETH_MAINNET_USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

        uint256 ownerBalanceBefore = IERC20(ETH_MAINNET_USDC_ADDRESS).balanceOf(OWNER);
        uint256 positionCountBefore = yieldAggregator.getUserPositionCount(OWNER);

        // ACT
        vm.warp(block.timestamp + 365 days);
        vm.roll(block.number + (365 days / 12));
        vm.prank(OWNER);
        yieldAggregator.withdraw(positionIndex);

        // ASSERT
        uint256 ownerBalanceAfter = IERC20(ETH_MAINNET_USDC_ADDRESS).balanceOf(OWNER);
        uint256 positionCountAfter = yieldAggregator.getUserPositionCount(OWNER);

        // Verify balance increased
        assertGt(ownerBalanceAfter, ownerBalanceBefore, "Owner balance should increase after withdrawal");
        // assertEq(ownerBalanceAfter, ownerBalanceBefore + 1e6); // This assertion line will fail because it accrued interest.

        // Verify position was removed
        assertEq(positionCountAfter, positionCountBefore - 1, "Position count should decrease by 1");
        assertEq(positionCountAfter, 0, "Should have 0 positions after withdrawal");
    }

    /// @notice Test that owner can withdraw successfully and receives funds from Aave
    function testOwnerCanWithdrawFromASpecificProtocolSuccessfully__Aave()
        external
        investedIntoASpecificProtocol__Aave
    {
        // ARRANGE
        //@notice This is the USDC address on Ethereum Sepolia network for aave
        address AAVE_ETH_SEPOLIA_USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        //@notice Aave V3 PoolAddressesProvider on Ethereum Sepolia

        uint256 ownerBalanceBefore = IERC20(AAVE_ETH_SEPOLIA_USDC_ADDRESS).balanceOf(OWNER);
        uint256 positionCountBefore = yieldAggregator.getUserPositionCount(OWNER);

        // ACT
        vm.warp(block.timestamp + 365 days);
        vm.roll(block.number + (365 days / 12));
        vm.prank(OWNER);
        yieldAggregator.withdraw(positionIndex);

        // ASSERT
        uint256 ownerBalanceAfter = IERC20(AAVE_ETH_SEPOLIA_USDC_ADDRESS).balanceOf(OWNER);
        uint256 positionCountAfter = yieldAggregator.getUserPositionCount(OWNER);

        // Verify balance increased
        assertGt(ownerBalanceAfter, ownerBalanceBefore, "Owner balance should increase after withdrawal");
        console2.log("Owner balance before withdrawal: ", ownerBalanceBefore);
        console2.log("Owner balance after withdrawal: ", ownerBalanceAfter);
        // assertEq(ownerBalanceAfter, ownerBalanceBefore + 1e6); // This assertion line will fail because it accrued interest.

        // Verify position was removed
        assertEq(positionCountAfter, positionCountBefore - 1, "Position count should decrease by 1");
        assertEq(positionCountAfter, 0, "Should have 0 positions after withdrawal");
    }

    /*//////////////////////////////////////////////////////////////
                        GETTER FUNCTIONS TESTS
    //////////////////////////////////////////////////////////////*/

    function testGetUserPositionsAfterInvestment() external investedIntoASpecificProtocol__Compound {
        // ACT
        yieldAggregator.getUserPositions(OWNER);
        yieldAggregator.getUserPositionCount(OWNER);
        yieldAggregator.getUserPositionByIndex(OWNER, positionIndex);
        uint256 userCurrentValue = yieldAggregator.getPositionValue(OWNER, positionIndex);
        uint256 userEarnedYield = yieldAggregator.getYieldEarned(OWNER, positionIndex);

        // ASSERT
        vm.expectRevert();
        yieldAggregator.getUserPositionByIndex(OWNER, positionIndex + 1);
        assertEq(positionIndex, 0);
        console2.log("User current value for position index ", positionIndex, "is", userCurrentValue);
        console2.log("User earned yield for position index ", positionIndex, "is", userEarnedYield);
    }

    function testGetUserValueAndEarnedYield__Aave() external {
        // ARRANGE
        uint256 INVESTED_AMOUNT = 1000e6;
        //@notice This is the USDC address on Ethereum Sepolia network for aave
        address AAVE_ETH_MAINNET_USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        //@notice Aave V3 PoolAddressesProvider on Ethereum Sepolia
        address AAVE_POOL_ADDRESSES_PROVIDER = 0x2f39d218133AFaB8F2B819B1066c7E434Ad94E9e;
        //@notice create a fork of Ethereum Sepolia network
        ethSepoliaFork = vm.createSelectFork("mainnet_eth");

        // ACT
        //@notice This funds the owner with some ETH to pay for gas fees
        vm.deal(OWNER, OWNER_ETH_BALANCE);
        //@notice Foundry cheatcode to send tokens to an address
        deal(AAVE_ETH_MAINNET_USDC_ADDRESS, OWNER, OWNER_USDC_BALANCE);
        //@notice for the test to work, I have to redeploy the yield aggregator contract since the createSelectFork changes the network context
        vm.prank(OWNER);
        yieldAggregator = new YieldAggregator();
        vm.prank(OWNER);
        aaveV3Adapter = new AaveV3Adapter(AAVE_POOL_ADDRESSES_PROVIDER);
        vm.prank(OWNER);
        yieldAggregator.addAdapter("aaveV3_USDC", address(aaveV3Adapter));

        vm.prank(OWNER);
        IERC20(AAVE_ETH_MAINNET_USDC_ADDRESS).forceApprove(address(yieldAggregator), OWNER_USDC_BALANCE); // note: owner has to approve YieldAggregator to spend her USDC tokens
        vm.prank(OWNER);
        positionIndex = yieldAggregator.invest(AAVE_ETH_MAINNET_USDC_ADDRESS, INVESTED_AMOUNT, "aaveV3_USDC");
        uint256 OWNER_USDC_BALANCE_AFTER_INVESTING = IERC20(AAVE_ETH_MAINNET_USDC_ADDRESS).balanceOf(OWNER);
        vm.warp(block.timestamp + 365 days);
        vm.roll(block.number + (365 days / 12));
        uint256 userEarnedYield = yieldAggregator.getYieldEarned(OWNER, positionIndex);
        uint256 userCurrentValue = yieldAggregator.getPositionValue(OWNER, positionIndex);

        // ASSERT
        console2.log("User earned yield for position index ", positionIndex, "is", userEarnedYield);
        console2.log("User current value for position index ", positionIndex, "is", userCurrentValue);
    }

    function testGetUserValueAndEarnedYield__Compound() external {
        // ARRANGE
        uint256 INVESTED_AMOUNT = 1000e6;
        //@notice This is the USDC address on Ethereum Mainnet network
        address ETH_MAINNET_USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        //@notice This is the Compound V3 Comet contract address for USDC on Ethereum Mainnet network
        address COMPOUND_ETH_MAINNET_USDC_ADDRESS = 0xc3d688B66703497DAA19211EEdff47f25384cdc3;
        //@notice create a fork of Ethereum Mainnet network
        ethSepoliaFork = vm.createSelectFork("mainnet_eth");

        // ACT
        //@notice This funds the owner with some ETH to pay for gas fees
        vm.deal(OWNER, OWNER_ETH_BALANCE);
        //@notice Foundry cheatcode to send tokens to an address
        deal(ETH_MAINNET_USDC_ADDRESS, OWNER, OWNER_USDC_BALANCE);
        //@notice for the test to work, I have to redeploy the yield aggregator contract since the createSelectFork changes the network context
        vm.prank(OWNER);
        yieldAggregator = new YieldAggregator();
        compoundV3Adapter = new CompoundV3Adapter(COMPOUND_ETH_MAINNET_USDC_ADDRESS);
        vm.prank(OWNER);
        yieldAggregator.addAdapter("compoundV3_USDC", address(compoundV3Adapter));

        vm.prank(OWNER);
        IERC20(ETH_MAINNET_USDC_ADDRESS).forceApprove(address(yieldAggregator), OWNER_USDC_BALANCE); // note: owner has to approve YieldAggregator to spend her USDC tokens
        vm.prank(OWNER);
        positionIndex = yieldAggregator.invest(ETH_MAINNET_USDC_ADDRESS, INVESTED_AMOUNT, "compoundV3_USDC");
        vm.warp(block.timestamp + 365 days);
        vm.roll(block.number + (365 days / 12));
        uint256 userEarnedYield = yieldAggregator.getYieldEarned(OWNER, positionIndex);
        uint256 userCurrentValue = yieldAggregator.getPositionValue(OWNER, positionIndex);

        // ASSERT
        console2.log("User earned yield for position index ", positionIndex, "is", userEarnedYield);
        console2.log("User current value for position index ", positionIndex, "is", userCurrentValue);
    }

    /*//////////////////////////////////////////////////////////////
                        RECEIVE FUNCTION TESTS
    //////////////////////////////////////////////////////////////*/
    function testReceiveFunctionReverts() external {
        // ARRANGE
        address sender = makeAddr("sender");
        vm.deal(sender, 1 ether);

        // ACT & ASSERT
        vm.prank(sender);
        vm.expectRevert(YieldAggregator.YieldAggregator__ETHDepositNotSupported.selector);

        (bool success,) = address(yieldAggregator).call{value: 1 ether}("");
    }

    /*//////////////////////////////////////////////////////////////
                        WITHDRAW ETH EDGE CASE TESTS
    //////////////////////////////////////////////////////////////*/
    function testWithdrawETHrevertsIfNotOwner() external {
        // ARRANGE
        address NON_OWNER = makeAddr("non_owner");

        // ACT & ASSERT
        vm.expectRevert();
        vm.prank(NON_OWNER);
        yieldAggregator.withdrawETH(payable(NON_OWNER), 1e18);
    }

    function testWithdrawETHRevertsIncaseOfInsufficientBalance() external {
        // ARRANGE
        address sender = makeAddr("sender");

        // ACT & ASSERT
        vm.prank(OWNER);
        vm.deal(sender, 1 ether);
        SelfDestruct selfDestructContract = new SelfDestruct();

        vm.prank(sender);
        (bool success,) = address(selfDestructContract).call{value: 1 ether}("");

        vm.prank(OWNER);
        selfDestructContract.destroy(payable(address(yieldAggregator)));

        vm.expectRevert(YieldAggregator.YieldAggregator__InsufficientETHBalance.selector);
        vm.prank(OWNER);
        yieldAggregator.withdrawETH(payable(OWNER), 2 ether);
    }

    function testWithdrawETHWorksIncaseOfSelfDestruct() external {
        // ARRANGE
        address sender = makeAddr("sender");

        // ACT
        vm.prank(OWNER);
        vm.deal(sender, 1 ether);
        SelfDestruct selfDestructContract = new SelfDestruct();

        vm.prank(sender);
        (bool success,) = address(selfDestructContract).call{value: 1 ether}("");

        vm.prank(OWNER);
        selfDestructContract.destroy(payable(address(yieldAggregator)));

        vm.prank(OWNER);
        yieldAggregator.withdrawETH(payable(OWNER), 1 ether);

        // ASSERT
        assertEq(OWNER.balance, 1 ether);
    }

    /*//////////////////////////////////////////////////////////////
                        MULTIPLE USERS EDGE CASE TESTS
    //////////////////////////////////////////////////////////////*/
    function testMultipleUsersCanInvestAndWithdrawSuccessfully__Aave() external {
        // ARRANGE
        uint256 INVESTED_AMOUNT = 1000e6;
        uint256 SECOND_USER_INVESTED_AMOUNT = 50000e6;

        //@notice This is the USDC address on Ethereum Sepolia network for aave
        address AAVE_ETH_MAINNET_USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        //@notice Aave V3 PoolAddressesProvider on Ethereum Sepolia
        address AAVE_POOL_ADDRESSES_PROVIDER = 0x2f39d218133AFaB8F2B819B1066c7E434Ad94E9e;
        //@notice create a fork of Ethereum Sepolia network
        ethSepoliaFork = vm.createSelectFork("mainnet_eth");

        // ACT
        //@notice This funds the owner and second user with some ETH to pay for gas fees
        vm.deal(OWNER, OWNER_ETH_BALANCE);
        vm.deal(SECOND_USER, SECOND_USER_ETH_BALANCE);

        //@notice Foundry cheatcode to send tokens to an address
        deal(AAVE_ETH_MAINNET_USDC_ADDRESS, OWNER, OWNER_USDC_BALANCE);
        deal(AAVE_ETH_MAINNET_USDC_ADDRESS, SECOND_USER, SECOND_USER_USDC_BALANCE);

        uint256 OWNER_USDC_BALANCE_BEFORE_INVESTING = IERC20(AAVE_ETH_MAINNET_USDC_ADDRESS).balanceOf(OWNER);
        //@notice for the test to work, I have to redeploy the yield aggregator contract since the createSelectFork changes the network context

        vm.prank(OWNER);
        yieldAggregator = new YieldAggregator();
        vm.prank(OWNER);
        aaveV3Adapter = new AaveV3Adapter(AAVE_POOL_ADDRESSES_PROVIDER);
        vm.prank(OWNER);
        yieldAggregator.addAdapter("aaveV3_USDC", address(aaveV3Adapter));

        vm.prank(OWNER);
        IERC20(AAVE_ETH_MAINNET_USDC_ADDRESS).forceApprove(address(yieldAggregator), OWNER_USDC_BALANCE); // note: owner has to approve YieldAggregator to spend her USDC tokens

        vm.prank(SECOND_USER);
        IERC20(AAVE_ETH_MAINNET_USDC_ADDRESS).forceApprove(address(yieldAggregator), SECOND_USER_USDC_BALANCE);

        vm.prank(OWNER);
        uint256 ownerPositionIndex =
            yieldAggregator.invest(AAVE_ETH_MAINNET_USDC_ADDRESS, INVESTED_AMOUNT, "aaveV3_USDC");

        uint256 OWNER_USDC_BALANCE_AFTER_INVESTING = IERC20(AAVE_ETH_MAINNET_USDC_ADDRESS).balanceOf(OWNER);

        vm.prank(SECOND_USER);
        uint256 secondUserPositionIndex =
            yieldAggregator.invest(AAVE_ETH_MAINNET_USDC_ADDRESS, SECOND_USER_INVESTED_AMOUNT, "aaveV3_USDC");

        vm.warp(block.timestamp + 365 days);
        vm.roll(block.number + (365 days / 12));

        vm.prank(OWNER);
        yieldAggregator.withdraw(ownerPositionIndex);

        vm.prank(SECOND_USER);
        yieldAggregator.withdraw(secondUserPositionIndex);

        // ASSERT
        uint256 ownerBalanceAfter = IERC20(AAVE_ETH_MAINNET_USDC_ADDRESS).balanceOf(OWNER);
        uint256 positionCountAfter = yieldAggregator.getUserPositionCount(OWNER);

        // Verify balance increased
        assertGt(ownerBalanceAfter, ownerBalanceBefore, "Owner balance should increase after withdrawal");
        console2.log("Owner balance before withdrawal: ", ownerBalanceBefore);
        console2.log("Owner balance after withdrawal: ", ownerBalanceAfter);

        assertEq(ownerPositionIndex, 0);
        console2.log("Owner invested amount: ", INVESTED_AMOUNT);
        
        assertEq(secondUserPositionIndex, 0);
        console2.log("Second user invested amount: ", SECOND_USER_INVESTED_AMOUNT);
    }

    /*//////////////////////////////////////////////////////////////
            ONE USER MULTIPLE INVESTMENT EDGE CASE TESTS
    //////////////////////////////////////////////////////////////*/
}
