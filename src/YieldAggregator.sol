// SPDX-License-Identifier: MIT

// Layout of the contract file:
// version
// imports
// interfaces, libraries, contract
// errors

// Inside Contract:
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private

// view & pure functions

pragma solidity ^0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title YieldAggregator
 * @author Kelechi Kizito Ugwu
 * @notice A DeFi Yield Aggregator contract that allows users to deposit assets into various yield-generating protocols.
 * It supports multiple protocols through adapters, tracks user positions, and offers auto-compounding features.
 * @dev
 */
contract YieldAggregator {
    /*//////////////////////////////////////////////////////////////
                              ERRORS
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
                            TYPE DECLARATIONS
    //////////////////////////////////////////////////////////////*/
    struct UserPosition {
        string protocolName; // "compound", "aave", etc.
        address token; // USDC, DAI, etc.
        uint256 principalAmount; // Original investment
        uint256 currentShares; // Protocol-specific shares/tokens
        uint256 depositTimestamp; // When invested
        bool autoCompoundEnabled; // User preference
        uint256 lastCompoundTime; // For auto-compound tracking
    }

    struct AutoCompoundSettings {
        bool enabled; // Global auto-compound toggle
        uint256 minRewardThreshold; // Minimum rewards to trigger compound
        uint256 maxGasPrice; // Max gas price willing to pay
        uint256 slippageTolerance; // Acceptable slippage (basis points)
    }

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    // User positions tracking
    mapping(address user => UserPosition[]) private s_userPositions;

    // Protocol adapters
    mapping(string => address) private s_protocolAdapters;

    // Auto-compound settings
    mapping(address => AutoCompoundSettings) private s_userSettings;
}
