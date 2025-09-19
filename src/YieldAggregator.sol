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
                            MODIFIERS
    /////////////////////////////////////////////////////////*/
    modifier invalidAmount(uint256 amount) {
        if (amount == 0) revert YieldAggregator__InvalidAmount();
        _;
    }

    /*/////////////////////////////////////////////////////////
                            CONSTRUCTOR
    /////////////////////////////////////////////////////////*/
    constructor() Ownable(msg.sender) {}

    /*//////////////////////////////////////////////////////////////
                        RECEIVE FUNCTION
    //////////////////////////////////////////////////////////////*/
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    /*//////////////////////////////////////////////////////////////
                        EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    // function invest(address token, uint256 amount, string memory preferredProtocol)
    //     external
    //     nonReentrant
    //     invalidAmount(amount)
    // {
    //     _invest(token, amount, preferredProtocol);
    // }

    /*////////////////////////////////////////////////////////////////
                        INTERNAL FUNCTIONS
    ////////////////////////////////////////////////////////////////*/
    /**
     * @notice Invest tokens into the best available yield protocol
     * @param token The token to invest
     * @param amount The amount to invest
     * @param preferredProtocol Optional protocol preference (empty string for auto-select)
     */
    // function _invest(address token, uint256 amount, string memory preferredProtocol) internal {
    //     if (IERC20(token).balanceOf(msg.sender) < amount) {
    //         revert YieldAggregator__InsufficientBalance();
    //     }

    //     // Determine target protocol
    //     string memory targetProtocol = preferredProtocol;
    //     if (bytes(preferredProtocol).length == 0) {
    //         targetProtocol = i_strategyManager.findBestYield(token, amount);  // What is the point of the strategy manager interface if we already have the file
    //     }

    //     if (s_protocolAdapters[targetProtocol] == address(0)) {
    //         revert YieldAggregator__ProtocolNotSupported();
    //     }

    //     // Execute investment
    //     IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
    //     IERC20(token).safeApprove(s_protocolAdapters[targetProtocol], amount);

    //     uint256 shares = IProtocolAdapter(s_protocolAdapters[targetProtocol]).deposit(amount, token);

    //     // Record position
    //     s_userPositions[msg.sender].push(
    //         UserPosition({
    //             protocolName: targetProtocol,
    //             token: token,
    //             principalAmount: amount,
    //             currentShares: shares,
    //             depositTimestamp: block.timestamp,
    //             autoCompoundEnabled: true,
    //             lastCompoundTime: block.timestamp
    //         })
    //     );

    //     emit InvestmentMade(msg.sender, targetProtocol, token, amount, shares);
    // }
}
