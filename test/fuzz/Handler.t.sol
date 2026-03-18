// SPDX-License-Identifier: MIT

// This Handler is going to narrow down the way we call functions

pragma solidity 0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {YieldAggregator} from "src/YieldAggregator.sol";
import {CompoundV3Adapter} from "src/adapters/CompoundV3Adapter.sol";
import {AaveV3Adapter} from "src/adapters/AaveV3Adapter.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";



contract Handler is Test {
    using SafeERC20 for IERC20;

    YieldAggregator public yieldAggregator;
    AaveV3Adapter public aaveV3Adapter;
    CompoundV3Adapter public compoundV3Adapter;
    IERC20 public usdc;

    // ✅ Ghost variables — track expected state independently of the contract
    mapping(address => uint256) public ghost_investCount;
    mapping(address => uint256) public ghost_withdrawCount;
    uint256 public ghost_totalInvests;
    uint256 public ghost_totalWithdrawals;

    // ✅ Track actors (multiple users)
    address[] public actors;
    address internal currentActor;

    uint256 constant MAX_INVEST_AMOUNT = 10_000e6; // 10,000 USDC
    uint256 constant MIN_INVEST_AMOUNT = 10e6;     // 10 USDC

    string constant AAVE_PROTOCOL = "aaveV3_USDC";
    string constant COMPOUND_PROTOCOL = "compoundV3_USDC";
    string[2] public protocols = [AAVE_PROTOCOL, COMPOUND_PROTOCOL];

    constructor(   YieldAggregator _yieldAggregator,
        AaveV3Adapter _aaveV3Adapter,
        CompoundV3Adapter _compoundV3Adapter, IERC20 _usdc,
        address[] memory _actors) {
        yieldAggregator = _yieldAggregator;
        aaveV3Adapter = _aaveV3Adapter;
        compoundV3Adapter = _compoundV3Adapter;
        usdc = _usdc;
        actors = _actors;
    }

    function invest(uint256 actorSeed, uint256 amount, uint256 protocolSeed) public {
        // STEP 1: Pick a random actor
        currentActor = actors[actorSeed % actors.length];

        // STEP 2: Bound amount to realistic range
        amount = bound(amount, MIN_INVEST_AMOUNT, MAX_INVEST_AMOUNT);

        // STEP 3: Pick a random protocol
        string memory protocol = protocols[protocolSeed % protocols.length];

        // STEP 4: Fund actor with USDC and approve
        deal(address(usdc), currentActor, amount);

        vm.startPrank(currentActor);
        usdc.forceApprove(address(yieldAggregator), amount);
        yieldAggregator.invest(address(usdc), amount, protocol);
        vm.stopPrank();

        // STEP 5: Update ghost variables
        ghost_investCount[currentActor]++;
        ghost_totalInvests++;
    }

    function withdraw(uint256 actorSeed, uint256 positionIndexSeed) public {
        // STEP 1: Pick a random actor
        currentActor = actors[actorSeed % actors.length];

        // STEP 2: Skip if actor has no positions — nothing to withdraw
        uint256 positionCount = yieldAggregator.getUserPositionCount(currentActor);
        if (positionCount == 0) return;

        // STEP 3: Bound positionIndex to valid range
        uint256 positionIndex = bound(positionIndexSeed, 0, positionCount - 1);

        // STEP 4: Withdraw
        vm.prank(currentActor);
        yieldAggregator.withdraw(positionIndex);

        // STEP 5: Update ghost variables
        ghost_withdrawCount[currentActor]++;
        ghost_totalWithdrawals++;
    }

    function getActors() external view returns (address[] memory) {
        return actors;
    }


}
