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

pragma solidity 0.8.26;

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
// Vulnerability: Unchecked balance assumptions. Never rely solely on address(this).balance for critical logic.
// Fix: Track deposits via a state variable (e.g., mapping(address => uint256) public deposits)/mapping(address => bool) public hasDeposited; instead of raw balance.
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

    /**
     * @dev The SafeERC20 library is used to safely handle ERC20 operations to prevent issues with non-standard ERC20 tokens, for example, USDT.
     */
    using SafeERC20 for IERC20;

    /// @dev This struct holds the information about a user's investment position in a specific protocol.
    struct UserPosition {
        string protocolName; // "compound", "aave", etc.
        address token; // USDC, DAI, etc.
        uint256 principalAmount; // Original investment
        uint256 currentShares; // Protocol-specific shares/tokens
        uint256 depositTimestamp; // Time When invested
        bool autoCompoundEnabled; // User preference for auto-compounding
        uint256 lastCompoundTime; // For auto-compound tracking(Last time rewards were reinvested)
    }

    /// @dev This struct holds the auto-compounding settings for a user.
    struct AutoCompoundSettings {
        bool enabled; // Global auto-compound toggle
        uint256 minRewardThreshold; // Minimum rewards to trigger compound
        uint256 maxGasPrice; // Max gas price willing to pay
        uint256 slippageTolerance; // Acceptable slippage (basis points)
    }

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    /// @dev The mapping tracking user positions
    mapping(address user => UserPosition[]) private s_userPositions;
    /// @dev The mapping of protocol names to their adapter contract addresses
    mapping(string protocolName => address adapterAddress) private s_protocolAdapters;
    /// @dev The mapping of user addresses to their auto-compounding settings
    mapping(address user => AutoCompoundSettings) private s_userSettings;
    IStrategyManager private immutable i_strategyManager;

    /*/////////////////////////////////////////////////////////
                            EVENTS
    /////////////////////////////////////////////////////////*/
    /// @notice Emitted when a ETH is sent to the contract, i.e. When the receive function is triggered
    event Deposit(address indexed sender, uint256 amount);
    event InvestmentMade(address indexed sender, string targetProtocol, address token, uint256 amount, uint256 shares);

    /*/////////////////////////////////////////////////////////
                            MODIFIERS
    /////////////////////////////////////////////////////////*/
    /// @notice Modifier to check if amount of ERC20 token is valid (greater than zero)
    /// @param amount The amount(ERC20 token) to validate
    modifier invalidAmount(uint256 amount) {
        if (amount == 0) revert YieldAggregator__InvalidAmount();
        _;
    }

    /*/////////////////////////////////////////////////////////
                            CONSTRUCTOR
    /////////////////////////////////////////////////////////*/
    constructor(address strategyManagerAddress) Ownable(msg.sender) {
        i_strategyManager = IStrategyManager(strategyManagerAddress); // Typecasting directly in the constructor means we just use i_strategyManager directly - no need to typecast again.
    }

    /*//////////////////////////////////////////////////////////////
                        RECEIVE FUNCTION
    //////////////////////////////////////////////////////////////*/
    /// @dev The receive function allows the contract to accept ETH deposits and emits a Deposit event.
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    /*//////////////////////////////////////////////////////////////
                        EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function addAdapter(string memory protocolName, address adapterAddress) external onlyOwner {
        _addAdapter(protocolName, adapterAddress);
    }

    function invest(address token, uint256 amount, string memory preferredProtocol)
        external
        nonReentrant
        invalidAmount(amount)
    {
        _invest(token, amount, preferredProtocol);
    }

    /*////////////////////////////////////////////////////////////////
                        INTERNAL FUNCTIONS
    ////////////////////////////////////////////////////////////////*/
    /**
     * @notice Adds a new protocol adapter to the Yield Aggregator
     * @param protocolName The name of the protocol (e.g., "compound", "aave")
     * @param adapterAddress The address of the protocol adapter contract
     */
    function _addAdapter(string memory protocolName, address adapterAddress) internal {
        s_protocolAdapters[protocolName] = adapterAddress;
    }

    /**
     * @notice Invest tokens into the best available yield protocol
     * @param token The token to invest
     * @param amount The amount to invest
     * @param preferredProtocol Optional protocol preference (empty string for auto-select)
     */
    function _invest(address token, uint256 amount, string memory preferredProtocol) internal {
        if (IERC20(token).balanceOf(msg.sender) < amount) {
            revert YieldAggregator__InsufficientBalance();
        }

        // Determine target protocol
        string memory targetProtocol = preferredProtocol;
        if (bytes(preferredProtocol).length == 0) {
            targetProtocol = i_strategyManager.findBestYield(token, amount); // What is the point of the strategy manager interface if we already have the file / also i still don't understand this loc, shouldn't the interface be typecasted to an address of the contract instance?
        }

        if (s_protocolAdapters[targetProtocol] == address(0)) {
            revert YieldAggregator__ProtocolNotSupported();
        }

        //2. Execute investment
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        // IERC20(token).safeApprove(s_protocolAdapters[targetProtocol], amount);

        uint256 shares = IProtocolAdapter(s_protocolAdapters[targetProtocol]).deposit(amount, token);

        // Record position
        s_userPositions[msg.sender]
        .push(
            UserPosition({
                protocolName: targetProtocol,
                token: token,
                principalAmount: amount,
                currentShares: shares,
                depositTimestamp: block.timestamp,
                autoCompoundEnabled: true,
                lastCompoundTime: block.timestamp
            })
        );

        emit InvestmentMade(msg.sender, targetProtocol, token, amount, shares);
    }

    /*//////////////////////////////////////////////////////////////
                    EXTERNAL VIEW & PURE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
}
