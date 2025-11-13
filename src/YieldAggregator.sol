// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

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
 * @notice The Yield Aggregator contract that allows users to deposit assets into various yield-generating protocols.
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
    error YieldAggregator__InvalidAdapterAddress();
    error YieldAggregator__InvalidToken();
    error YieldAggregator__InvalidSharesReceived();
    error YieldAggregator__ETHDepositNotSupported();
    error YieldAggregator__InsufficientETHBalance();
    error YieldAggregator__FailedETHWithdrawal();

    /*//////////////////////////////////////////////////////////////
                            TYPE DECLARATIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev The SafeERC20 library is used to safely handle ERC20 operations to prevent issues with non-standard ERC20 tokens, for example, USDT.
     * @notice This means for every IERC20 token, we can now call the safeTransfer, safeTransferFrom, and safeApprove functions provided by the SafeERC20 library.
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
    mapping(address user => UserPosition[]) private s_userPositions; // the mapping is to an array because one user can have multiple positions
    /// @dev The mapping of protocol names to their adapter contract addresses
    mapping(string protocolName => address adapterAddress) private s_protocolAdapters;
    /// @dev The mapping of user addresses to their auto-compounding settings
    mapping(address user => AutoCompoundSettings) private s_userSettings;

    IStrategyManager private immutable i_strategyManager;

    /*/////////////////////////////////////////////////////////
                            EVENTS
    /////////////////////////////////////////////////////////*/

    // / @notice Emitted when a ETH is sent to the contract, i.e. When the receive function is triggered
    // event Deposit(address indexed sender, uint256 amount);
    event InvestmentMade(
        address indexed sender, string indexed targetProtocol, address indexed token, uint256 amount, uint256 shares
    );
    event Withdrawal(address indexed sender, string indexed protocolName, uint256 indexed amount);
    event ETHWithdrawal(address indexed to, uint256 indexed amount);
    event AdapterAdded(string indexed protocolName, address indexed adapterAddress);
    event AutoCompoundSettingsChanged(
        address indexed sender, bool enabled, uint256 minReward, uint256 maxGas, uint256 slippage
    );

    /*/////////////////////////////////////////////////////////
                            MODIFIERS
    /////////////////////////////////////////////////////////*/

    /// @notice Modifier to check if amount of ERC20 token is valid (greater than zero)
    /// @param amount The amount(ERC20 token) to validate
    modifier validAmount(uint256 amount) {
        if (amount == 0) revert YieldAggregator__InvalidAmount();
        _;
    }

    modifier noneZeroAddress(address adapterAddress) {
        if (adapterAddress == address(0)) revert YieldAggregator__InvalidAdapterAddress();
        _;
    }

    modifier validToken(address token) {
        if (token == address(0)) revert YieldAggregator__InvalidToken();
        _;
    }

    /*/////////////////////////////////////////////////////////
                            CONSTRUCTOR
    /////////////////////////////////////////////////////////*/

    constructor(address strategyManagerAddress) Ownable(msg.sender) noneZeroAddress(strategyManagerAddress) {
        i_strategyManager = IStrategyManager(strategyManagerAddress); // Typecasting directly in the constructor means we just use i_strategyManager directly - no need to typecast again.
    }

    /*//////////////////////////////////////////////////////////////
                        RECEIVE FUNCTION
    //////////////////////////////////////////////////////////////*/

    /// @dev The receive function doesn't accept ETH, meaning this contract doesn't accept ETH.
    receive() external payable {
        revert YieldAggregator__ETHDepositNotSupported();
    }

    /*//////////////////////////////////////////////////////////////
                        EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Its internal function withdraws ETH from the contract to a specified address. Although this contract can't receive ETH, this function is added in case this contract has been specified in a selfdestruct. (selfdestruct edge case)
     * @param to The address to send the ETH to
     * @param amount The amount of ETH to withdraw
     */
    function withdrawETH(address payable to, uint256 amount) external nonReentrant onlyOwner {
        _withdrawETH(to, amount);
    }

    function addAdapter(string memory protocolName, address adapterAddress)
        external
        nonReentrant
        noneZeroAddress(adapterAddress)
        onlyOwner
    {
        _addAdapter(protocolName, adapterAddress);
    }

    function setAutoCompoundSettings(bool enabled, uint256 minReward, uint256 maxGas, uint256 slippage) external {
        _setAutoCompoundSettings(enabled, minReward, maxGas, slippage);
    }

    function withdraw(uint256 positionIndex) external nonReentrant {
        _withdraw(positionIndex);
    }

    function invest(address token, uint256 amount, string memory preferredProtocol)
        external
        nonReentrant
        validAmount(amount)
        validToken(token)
    {
        _invest(token, amount, preferredProtocol);
    }

    /*////////////////////////////////////////////////////////////////
                        INTERNAL FUNCTIONS
    ////////////////////////////////////////////////////////////////*/

    /**
     * @dev Internal function to withdraw ETH from the contract to a specified address. Although this contract can't receive ETH, this function is added in case this contract has been specified in a selfdestruct. (selfdestruct edge case)
     * @param to The address to send the ETH to
     * @param amount The amount of ETH to withdraw
     */
    function _withdrawETH(address payable to, uint256 amount) internal {
        // CHECKS
        if (address(this).balance < amount) {
            revert YieldAggregator__InsufficientETHBalance();
        }

        // EFFECTS

        // INTERACTIONS
        (bool success,) = to.call{value: amount}("");
        if (!success) {
            revert YieldAggregator__FailedETHWithdrawal();
        }

        emit ETHWithdrawal(to, amount);
    }

    /**
     * @notice Adds a new protocol adapter to the Yield Aggregator
     * @param protocolName The name of the protocol (e.g., "compound", "aave")
     * @param adapterAddress The address of the protocol adapter contract
     */
    function _addAdapter(string memory protocolName, address adapterAddress) internal {
        s_protocolAdapters[protocolName] = adapterAddress;

        emit AdapterAdded(protocolName, adapterAddress);
    }

    /**
     * @dev Sets the auto-compounding settings for the caller.
     * @param enabled true to enable auto-compounding, false to disable
     * @param minReward the minimum reward threshold to trigger auto-compounding
     * @param maxGas the maximum gas price the user is willing to pay for auto-compounding
     * @param slippage the acceptable slippage tolerance in basis points (bps)
     */
    function _setAutoCompoundSettings(bool enabled, uint256 minReward, uint256 maxGas, uint256 slippage) internal {
        s_userSettings[msg.sender] = AutoCompoundSettings({
            enabled: enabled, minRewardThreshold: minReward, maxGasPrice: maxGas, slippageTolerance: slippage
        });

        emit AutoCompoundSettingsChanged(msg.sender, enabled, minReward, maxGas, slippage);
    }

    /**
     * @notice Withdraw funds from a specific investment position
     * @dev This withdraw function meticulously follows the CEI pattern to double down on a potential reentrancy vulnerability, albeit, its external implementation is protected by the nonReentrant modifier.
     * @param positionIndex The index of the user's investment position to withdraw from. You can find it externally by calling `getUserPositions` or `getUserPositionCount`.
     */
    function _withdraw(uint256 positionIndex) internal {
        // ✅ CHECKS
        // STEP 1: this line retrieves all investment positions for the user calling the function.
        UserPosition[] storage userInvestmentPositions = s_userPositions[msg.sender];
        // STEP 2: position validation, This line validates if the investment position exists for the user.
        if (positionIndex >= userInvestmentPositions.length) {
            revert YieldAggregator__PositionNotFound();
        }

        // Step 3: this line gets the position details for the specified index.
        UserPosition memory position = userInvestmentPositions[positionIndex]; // this line remains holds the same variable even after swap and pop removal because it has already been defined in memory. defining it in memory makes a copy of the intended struct rather than referencing the original/storage struct so any changes to the storage array won't affect this copy.
        // STEP 4: Get the adapter (the bridge to that protocol)
        address adapter = s_protocolAdapters[position.protocolName];
        if (adapter == address(0)) {
            revert YieldAggregator__ProtocolNotSupported();
        }

        // ✅ EFFECTS
        // STEP 5: Remove the position from the user's array
        // to-do: convert to an internal function
        // These lines affect the STORAGE (blockchain), NOT the memory copy:
        userInvestmentPositions[positionIndex] = userInvestmentPositions[userInvestmentPositions.length - 1];
        userInvestmentPositions.pop();

        // ✅ INTERACTIONS
        // STEP 6: Call the withdraw function on the adapter
        uint256 amountWithdrawn = IProtocolAdapter(adapter).withdraw(position.currentShares, position.token); // position.currentShares is the single source of truth for "how much can this user withdraw

        // STEP 7: Transfer the withdrawn amount back to the user
        IERC20(position.token).safeTransfer(msg.sender, amountWithdrawn);

        // ✅ EVENT
        emit Withdrawal(msg.sender, position.protocolName, amountWithdrawn);
    }

    /**
     * @notice Invest tokens into the best available yield protocol
     * @dev This function negates CEI pattern because the deposit function in the adapter needs the tokens to be already in the contract before it can proceed.
     * @param token The token to invest
     * @param amount The amount to invest
     * @param preferredProtocol Optional protocol preference (empty string for auto-select)
     */
    function _invest(address token, uint256 amount, string memory preferredProtocol) internal {
        // ✅ CHECKS
        // STEP 1: Check if the user's token balance is sufficient
        if (IERC20(token).balanceOf(msg.sender) < amount) {
            revert YieldAggregator__InsufficientBalance();
        }

        // STEP 2: Determine target protocol
        string memory targetProtocol = preferredProtocol;
        // this conditional means that if a user doesn't provide a preferredProtocol, i.e, if the preferredProtocol is empty, the strategymanager should find the best protocol for the particular token
        if (bytes(preferredProtocol).length == 0) {
            targetProtocol = i_strategyManager.findBestYield(token, amount);
        }

        // STEP 3: Check if the protocol adapter exists in your mapping
        address adapter = s_protocolAdapters[targetProtocol];
        if (adapter == address(0)) {
            revert YieldAggregator__ProtocolNotSupported();
        }

        // ✅ INTERACTIONS
        // STEP 4: Transfer tokens from user to this contract
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount); // Only pass from, to, and amount — the token is already bound by using SafeERC20 for IERC20// Get the tokens from the user
        // STEP 5: Approves the adapter to spend the tokens
        IERC20(token).forceApprove(adapter, amount); // Give permission to the adapter to use those tokens
        // STEP 6: The adapter deposits the tokens into the respective protocols to get back shares
        uint256 shares = IProtocolAdapter(adapter).deposit(amount, token); // This calls the adapter to deposit (it will use its permission)

        uint256 invalidShares = 0;
        // uint256 MIN_SHARES = 1000;
        if (shares == invalidShares) {
            revert YieldAggregator__InvalidSharesReceived();
        } // isn't it possible for shares to be zero?
        // if (shares < amount / MIN_SHARES) {
        //     // Less than 0.1% of deposit
        //     revert YieldAggregator__InvalidSharesReceived();
        // }

        // ✅ EFFECTS
        // STEP 7: Record the position
        s_userPositions[msg.sender]
        .push(
            UserPosition({
                protocolName: targetProtocol,
                token: token,
                principalAmount: amount,
                currentShares: shares, // Record the position with the shares you got back
                depositTimestamp: block.timestamp,
                autoCompoundEnabled: true, // Default enabled
                lastCompoundTime: block.timestamp
            })
        );

        // STEP 8: Emit event
        emit InvestmentMade(msg.sender, targetProtocol, token, amount, shares);
    }

    /*//////////////////////////////////////////////////////////////
                    EXTERNAL VIEW & PURE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev A getter function that returns all investment positions for a user.
     * @param user The address of the user whose positions are to be retrieved.
     * @return An array of UserPosition structs representing the user's investment positions.
     */
    function getUserPositions(address user) external view returns (UserPosition[] memory) {
        return s_userPositions[user];
    }

    /**
     * @dev A getter function that returns the total number of investment positions for a user.
     * @return The length of the user's investment positions array, i.e., the total number of investment positions.
     */
    function getUserPositionCount(address user) external view returns (uint256) {
        return s_userPositions[user].length;
    }

    /**
     * @dev This function retrieves a specific user position by its index.
     * @param user The address of the user whose position is to be retrieved.
     * @param index The index of the position in the user's positions array.
     * @return The UserPosition struct at the specified index.
     * @notice Get a specific position by index
     */
    function getUserPositionByIndex(address user, uint256 index) external view returns (UserPosition memory) {
        if (index >= s_userPositions[user].length) {
            revert YieldAggregator__PositionNotFound();
        }
        return s_userPositions[user][index];
    }
}
