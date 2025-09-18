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
import {IProtocolAdapter} from "src/interfaces/IProtocolAdapter.sol";
import {IStrategyManager} from "src/interfaces/IStrategyManager.sol";

// **APIs to Research:**
// - DefiLlama API (aggregated DeFi data)
// - Individual protocol APIs (Compound, Aave, Uniswap)
// - Price feeds (CoinGecko, CoinMarketCap)

/**
 * @title YieldAggregator
 * @author Kelechi Kizito Ugwu
 * @notice A DeFi Yield Aggregator contract that allows users to deposit assets into various yield-generating protocols.
 * It supports multiple protocols through adapters, tracks user positions, and offers auto-compounding features.
 * @dev
 */
contract YieldAggregator is ReentrancyGuard, Ownable {
    /*//////////////////////////////////////////////////////////////
                              ERRORS
    //////////////////////////////////////////////////////////////*/
    error YieldAggregator__InsufficientBalance();
    error YieldAggregator__ProtocolNotSupported();
    error YieldAggregator__InvalidAmount();
    error YieldAggregator__PositionNotFound();

    /*//////////////////////////////////////////////////////////////
                            TYPE DECLARATIONS
    //////////////////////////////////////////////////////////////*/
    using SafeERC20 for IERC20;

    struct UserPosition {
        string protocolName; // "compound", "aave", etc.
        address token; // USDC, DAI, etc.
        uint256 principalAmount; // Original investment
        uint256 currentShares; // Protocol-specific shares/tokens
        uint256 depositTimestamp; // When invested
        bool autoCompoundEnabled; // User preference
        uint256 lastCompoundTime; // For auto-compound tracking
    }

//     UserPosition { This is Alice's(user) position after investing 1000 USDC in compound
//     protocolName: "compound",           // Where her money went
//     token: 0xA0b86a33E6....,           // USDC contract address  
//     principalAmount: 1000000000,        // $1000 USDC (6 decimals)
//     currentShares: 47500000,            // 47.5 cUSDC tokens she received
//     depositTimestamp: 1694567890,       // Sept 12, 2024 3:45 PM
//     autoCompoundEnabled: true,          // She wants auto-reinvesting
//     lastCompoundTime: 1694567890        // Last time rewards were reinvested
// }

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
    mapping(address user => AutoCompoundSettings) private s_userSettings;

    /*/////////////////////////////////////////////////////////
                            EVENTS
    /////////////////////////////////////////////////////////*/
    event Deposit(address indexed sender, uint256 amount);

    
    /*/////////////////////////////////////////////////////////
                            CONSTRUCTOR
    /////////////////////////////////////////////////////////*/
    constructor() Ownable(msg.sender) {
        
    }

    /*//////////////////////////////////////////////////////////////
                        RECEIVE FUNCTION
    //////////////////////////////////////////////////////////////*/
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    /*//////////////////////////////////////////////////////////////
                        EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
}
