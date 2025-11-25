// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IProtocolAdapter} from "src/interfaces/IProtocolAdapter.sol";
// import {CometMainInterface} from "@comet/contracts/CometMainInterface.sol"; // or do you reckon i import the interface instead of the main contract in my adapter contract?
import {IComet} from "src/interfaces/IComet.sol"; // importing the interface is the  correct and best approach when building protocol adapters
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// note: The Compound Main Proxy Contract interacts with the Compound III. It Handles all deposits (supply) and withdrawals. It Calculates your earnings and Manages borrowing.
// note: the reward contract is useful for the auto-compound feature.
// note: the bulker contract for advanced features
// note: Each token has its own separate Comet market. Compound V3 created isolated markets - meaning each token (USDC, USDT, ETH, etc.) has its own separate Comet contract.

/**
 * @title CompoundV3Adapter
 * @author Kelechi Kizito Ugwu
 * @notice Adapter contract for interacting with the Compound V3 protocol.
 * @dev
 */
// Q: Will I need to add access control for which contracts can call these functions?
// note: this contract is abstract because it hasn't implemented ALL the interface functions
contract CompoundV3Adapter is IProtocolAdapter {
    //     supply()

    // withdraw()

    // getAssetInfo()

    // balanceOf()
    error CompoundV3Adapter__InvalidCometAddress();
    // error CompoundV3Adapter__InvalidYieldAggregatorAddress();
    // error CompoundV3Adapter__UnauthorizedCaller();

    using SafeERC20 for IERC20;

    // this interface will be typecasted to the compound main contract address. The main contract address in this case, will be dependent on the network you choose, and token.
    IComet private immutable i_comet;
    // address private immutable i_yieldAggregator;

    // modifier onlyYieldAggregator() {
    //     if (msg.sender == i_yieldAggregator) {
    //         revert CompoundV3Adapter__UnauthorizedCaller();
    //     }
    //     _;
    // }

    constructor(
        address _comet /*,address _yieldAggregator*/
    ) {
        if (_comet == address(0)) revert CompoundV3Adapter__InvalidCometAddress();
        // if (_yieldAggregator == address(0)) revert CompoundV3Adapter__InvalidYieldAggregatorAddress();
        i_comet = IComet(_comet);
        // i_yieldAggregator = _yieldAggregator;
    }

    // ### **What Your Adapter MUST Do:**
    // ```
    // 1. Pull tokens FROM YieldAggregator TO adapter
    // 2. Approve Comet to spend those tokens
    // 3. Call Comet's supply function
    // 4. Calculate shares received
    // 5. Return shares to YieldAggregator
    function deposit(uint256 amount, address token) external returns (uint256 shares) {
        // Pull tokens from YieldAggregator(msg.sender) to this adapter
        IERC20(token).transferFrom(msg.sender, address(this), amount);

        // check the balance of shares before token supply
        uint256 balanceBeforeSupply = i_comet.balanceOf(address(this));

        // Approve Comet to spend those tokens
        IERC20(token).forceApprove(address(i_comet), amount);

        // Tell Comet to take the tokens and give us shares
        i_comet.supply(token, amount);

        // Check how many shares we have now, after token supply
        uint256 balanceAfterSupply = i_comet.balanceOf(address(this));

        // Calculate the shares we received
        shares = balanceAfterSupply - balanceBeforeSupply;

        return shares;
    }

    // In Compound V3, "shares" and "amount" are essentially the same thing
    function withdraw(uint256 shares, address token) external returns (uint256 amount) {
        // In Compound V3, when you withdraw "shares", you're actually withdrawing
        // that amount from your balance

        // STEP 1: Withdraw from Compound (this burns shares and gives tokens to adapter)
        i_comet.withdraw(token, shares);

        amount = IERC20(token).balanceOf(address(this));

        // STEP 3: Transfer tokens back to YieldAggregator
        IERC20(token).safeTransfer(msg.sender, amount);

        // STEP 4: Return amount
        return amount;
    }

    // returns the total balance of shares the adapter has in Comet
    function getBalance() external view returns (uint256) {
        return i_comet.balanceOf(address(this));
    }

    // function getAssetInfo(uint8 i) external view returns (AssetInfo memory) {
    // }

    function getCometAddress() external view returns (address) {
        return address(i_comet);
    }
}

