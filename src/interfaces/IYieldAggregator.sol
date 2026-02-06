// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title IYieldAggregator
 * @author Kelechi Kizito Ugwu
 * @notice Interface for the Yield Aggregator contract
 * @dev This interface defines all external functions for the YieldAggregator
 *      Currently supports two protocols: Aave V3 and Compound V3
 */
interface IYieldAggregator {
    /*//////////////////////////////////////////////////////////////
                        TYPE DECLARATIONS & STRUCTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Represents a user's investment position in a specific protocol
     */
    struct UserPosition {
        string protocolName; // "aave" or "compound"
        address token; // USDC, DAI, etc.
        uint256 principalAmount; // Original investment amount
        uint256 currentShares; // Protocol-specific shares/tokens
        uint256 depositTimestamp; // When the investment was made
        bool autoCompoundEnabled; // Auto-compound preference
        uint256 lastCompoundTime; // Last time rewards were compounded
    }

    /**
     * @dev Auto-compounding configuration for a user
     */
    struct AutoCompoundSettings {
        bool enabled; // Global auto-compound toggle
        uint256 minRewardThreshold; // Minimum rewards to trigger compound
        uint256 maxGasPrice; // Max gas price willing to pay
        uint256 slippageTolerance; // Acceptable slippage (basis points)
    }

    /*//////////////////////////////////////////////////////////////
                              EVENTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Emitted when a user makes an investment
     */
    event InvestmentMade(
        address indexed user, string targetProtocol, address indexed token, uint256 amount, uint256 indexed shares
    );

    /**
     * @dev Emitted when a user withdraws from a position
     */
    event Withdrawal(address indexed user, string indexed protocolName, uint256 indexed amount);

    /**
     * @dev Emitted when a protocol adapter is added
     */
    event AdapterAdded(string indexed protocolName, address indexed adapterAddress);

    /**
     * @dev Emitted when auto-compound settings are updated
     */
    event AutoCompoundSettingsChanged(
        address indexed user, bool enabled, uint256 minReward, uint256 maxGas, uint256 slippage
    );

    /**
     * @dev Emitted when ETH is withdrawn from the contract
     */
    event ETHWithdrawal(address indexed to, uint256 indexed amount);

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
                        INVESTMENT FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Invest tokens into a specified yield protocol
     * @dev User must approve this contract to spend their tokens first
     * @param token The token address to invest (e.g., USDC, DAI)
     * @param amount The amount of tokens to invest
     * @param preferredProtocol The protocol to invest in ("aave" or "compound")
     * @return positionIndex The index of the created position
     */
    function invest(address token, uint256 amount, string memory preferredProtocol)
        external
        returns (uint256 positionIndex);

    /**
     * @notice Withdraw funds from a specific investment position
     * @dev Burns the position and transfers tokens back to the user
     * @param positionIndex The index of the position to withdraw from
     */
    function withdraw(uint256 positionIndex) external;

    /*//////////////////////////////////////////////////////////////
                        ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Add a new protocol adapter (Owner only)
     * @dev Links a protocol name to its adapter contract address
     * @param protocolName The name of the protocol ("aave" or "compound")
     * @param adapterAddress The address of the protocol adapter contract
     */
    function addAdapter(string memory protocolName, address adapterAddress) external;

    /**
     * @notice Withdraw ETH from the contract (Owner only)
     * @dev Emergency function for selfdestruct edge case
     * @param to The address to send ETH to
     * @param amount The amount of ETH to withdraw
     */
    function withdrawETH(address payable to, uint256 amount) external;

    /*//////////////////////////////////////////////////////////////
                        USER SETTINGS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Set auto-compound settings for the caller
     * @param enabled Whether to enable auto-compounding
     * @param minReward Minimum reward threshold to trigger compound
     * @param maxGas Maximum gas price willing to pay
     * @param slippage Acceptable slippage tolerance (basis points)
     */
    function setAutoCompoundSettings(bool enabled, uint256 minReward, uint256 maxGas, uint256 slippage) external;

    /*//////////////////////////////////////////////////////////////
                        VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Get the current value of a user's position including accrued yield
     * @param user The user's address
     * @param positionIndex The index of the position
     * @return currentValue The current value in underlying tokens
     */
    function getPositionValue(address user, uint256 positionIndex) external view returns (uint256 currentValue);

    /**
     * @notice Get the yield earned on a specific position
     * @param user The user's address
     * @param positionIndex The index of the position
     * @return yieldEarned The amount of yield earned (currentValue - principal)
     */
    function getYieldEarned(address user, uint256 positionIndex) external view returns (uint256 yieldEarned);

    /**
     * @notice Get all investment positions for a user
     * @param user The address of the user
     * @return An array of UserPosition structs
     */
    function getUserPositions(address user) external view returns (UserPosition[] memory);

    /**
     * @notice Get the total number of positions for a user
     * @param user The address of the user
     * @return The count of positions
     */
    function getUserPositionCount(address user) external view returns (uint256);

    /**
     * @notice Get a specific position by index
     * @param user The address of the user
     * @param index The index of the position
     * @return The UserPosition struct at the specified index
     */
    function getUserPositionByIndex(address user, uint256 index) external view returns (UserPosition memory);
}
