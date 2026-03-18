// SPDX-License-Identifier: MIT

// Invariants that must always hold true:
// 1. Position count per user must always equal their invests minus their withdrawals
// 2. YieldAggregator must never hold USDC (tokens pass through to adapter)
// 3. YieldAggregator must never hold ETH
// 4. Getter/view functions must never revert

pragma solidity 0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {YieldAggregator} from "src/YieldAggregator.sol";
import {AaveV3Adapter} from "src/adapters/AaveV3Adapter.sol";
import {CompoundV3Adapter} from "src/adapters/CompoundV3Adapter.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Handler} from "test/fuzz/Handler.t.sol";

contract YieldAggregatorInvariants is StdInvariant, Test {
    YieldAggregator yieldAggregator;
    AaveV3Adapter aaveV3Adapter;
    CompoundV3Adapter compoundV3Adapter;
    IERC20 usdc;
    Handler handler;

    address public OWNER = makeAddr("owner");
    address public ALICE = makeAddr("alice");
    address public BOB = makeAddr("bob");
    address public CHARLIE = makeAddr("charlie");

    address USDC_MAINNET = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address AAVE_POOL_ADDRESSES_PROVIDER = 0x2f39d218133AFaB8F2B819B1066c7E434Ad94E9e;
    address COMPOUND_COMET = 0xc3d688B66703497DAA19211EEdff47f25384cdc3;

    function setUp() external {
        vm.createSelectFork("mainnet_eth");

        vm.startPrank(OWNER);
        yieldAggregator = new YieldAggregator();
        aaveV3Adapter = new AaveV3Adapter(AAVE_POOL_ADDRESSES_PROVIDER);
        compoundV3Adapter = new CompoundV3Adapter(COMPOUND_COMET);
        yieldAggregator.addAdapter("aaveV3_USDC", address(aaveV3Adapter));
        yieldAggregator.addAdapter("compoundV3_USDC", address(compoundV3Adapter));
        vm.stopPrank();

        usdc = IERC20(USDC_MAINNET);

        address[] memory actors = new address[](3);
        actors[0] = ALICE;
        actors[1] = BOB;
        actors[2] = CHARLIE;

        handler = new Handler(yieldAggregator, aaveV3Adapter, compoundV3Adapter, usdc, actors);

        targetContract(address(handler));
    }

    /*//////////////////////////////////////////////////////////////
                            INVARIANTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Position count per user must always equal invests minus withdrawals
    function invariant_positionCountMatchesNetInvests() public view {
        address[] memory actors = handler.getActors();

        for (uint256 i = 0; i < actors.length; i++) {
            address actor = actors[i];
            uint256 actualPositionCount = yieldAggregator.getUserPositionCount(actor);
            uint256 expectedPositionCount = handler.ghost_investCount(actor) - handler.ghost_withdrawCount(actor);

            console2.log("Actor: ", actor);
            console2.log("Actual position count: ", actualPositionCount);
            console2.log("Expected position count: ", expectedPositionCount);
            console2.log("Ghost invest count: ", handler.ghost_investCount(actor));
            console2.log("Ghost withdraw count: ", handler.ghost_withdrawCount(actor));

            assertEq(actualPositionCount, expectedPositionCount, "Position count must equal invests minus withdrawals");
        }
    }

    /// @notice YieldAggregator must never hold USDC — tokens must always pass through to adapter
    function invariant_contractNeverHoldsUSDC() public view {
        uint256 yieldAggregatorUSDCBalance = usdc.balanceOf(address(yieldAggregator));

        console2.log("YieldAggregator USDC balance: ", yieldAggregatorUSDCBalance);
        console2.log("Total invests: ", handler.ghost_totalInvests());
        console2.log("Total withdrawals: ", handler.ghost_totalWithdrawals());

        assertEq(yieldAggregatorUSDCBalance, 0, "YieldAggregator must never hold USDC");
    }

    /// @notice YieldAggregator must never hold ETH — receive() always reverts
    function invariant_contractNeverHoldsETH() public view {
        assertEq(address(yieldAggregator).balance, 0, "YieldAggregator must never hold ETH");
    }

    /// @notice All getter/view functions must never revert regardless of state
    function invariant_getterViewFunctionsShouldNeverRevert() public view {
        address[] memory actors = handler.getActors();

        for (uint256 i = 0; i < actors.length; i++) {
            address actor = actors[i];
            uint256 positionCount = yieldAggregator.getUserPositionCount(actor);

            yieldAggregator.getUserPositions(actor);
            yieldAggregator.getUserPositionCount(actor);

            if (positionCount > 0) {
                yieldAggregator.getUserPositionByIndex(actor, 0);
            }
        }
    }
}
