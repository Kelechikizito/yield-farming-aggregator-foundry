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
 * @dev Each Comet contract handles one specific base token (USDC, USDT, WETH, etc.)
 */
// Q: Will I need to add access control for which contracts can call these functions?
// note: this contract is abstract because it hasn't implemented ALL the interface functions
contract CompoundV3Adapter is IProtocolAdapter {
    // getAssetInfo()

    // balanceOf()
    error CompoundV3Adapter__InvalidCometAddress();
    // error CompoundV3Adapter__InvalidYieldAggregatorAddress();
    // error CompoundV3Adapter__UnauthorizedCaller();

    using SafeERC20 for IERC20;

    // this interface will be typecasted to the compound main contract address. The main contract address in this case, will be dependent on the network you choose, and token.
    IComet private immutable i_comet;
    // address private immutable i_yieldAggregator;
    /// @dev Total shares issued across ALL user positions in this adapter
    /// This is the denominator for proportional value calculation
    uint256 private s_totalShares;

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

    function deposit(address token, uint256 amount) external returns (uint256 shares) {
        // Pull tokens from YieldAggregator(msg.sender) to this adapter
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

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

        // This step tracks total shares so getShareValue can calculate proportional value
        s_totalShares += shares;

        return shares;
    }

    // In Compound V3, "shares" and "amount" are essentially the same thing
    function withdraw(address token, uint256 shares) external returns (uint256 amount) {
        // Calculate what this user's shares are worth RIGHT NOW
        uint256 totalCometBalance = i_comet.balanceOf(address(this));
        uint256 proportionalAmount = (shares * totalCometBalance) / s_totalShares;
        //      ↑ 999,999,999 * 1,025,153,233 / 999,999,999 = 1,025,153,233 ✅

        uint256 balanceBeforeWithdrawal = IERC20(token).balanceOf(address(this));

        i_comet.withdraw(token, proportionalAmount); // withdraw full value including yield

        uint256 balanceAfterWithdrawal = IERC20(token).balanceOf(address(this));
        amount = balanceAfterWithdrawal - balanceBeforeWithdrawal;

        s_totalShares -= shares; // burn user's shares from total

        IERC20(token).safeTransfer(msg.sender, amount);
        return amount;
    }

    function getShareValue(
        address,
        /*token*/
        uint256 shares
    )
        external
        returns (uint256)
    {
        if (s_totalShares == 0) return 0;

        uint256 totalCometBalance = i_comet.balanceOf(address(this));

        // Proportional value: user's fraction of total pool × current pool value
        return (shares * totalCometBalance) / s_totalShares;
    }

    // returns the total balance of shares the adapter has in Comet
    function getBalance() external view returns (uint256) {
        return i_comet.balanceOf(address(this));
    } // question why doesn't this comet implementation have token parameter like the aave one?

    function getCometAddress() external view returns (address) {
        return address(i_comet);
    }
}

