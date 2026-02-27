// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IProtocolAdapter} from "src/interfaces/IProtocolAdapter.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
/// @dev This interface contract is the interface for the main user-facing contract for aave protocol - This is like Comet for Compound
import {IPool} from "@aave/core-v3/contracts/interfaces/IPool.sol";
import {DataTypes} from "@aave/core-v3/contracts/protocol/libraries/types/DataTypes.sol";
import {IPoolAddressesProvider} from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import {WadRayMath} from "@aave/core-v3/contracts/protocol/libraries/math/WadRayMath.sol";
import {IAToken} from "@aave/core-v3/contracts/interfaces/IAToken.sol";

/**
 * @title AaveV3Adapter
 * @author Kelechi Kizito Ugwu
 * @notice Adapter contract for interacting with the Aave V3 protocol.
 * @dev Uses IPoolAddressesProvider to get the current Pool address dynamically.
 * Uses getReserveData() to fetch aToken addresses automatically.
 */
// note: The aave pool contract is the main entry point into the AAVE protocol
contract AaveV3Adapter is IProtocolAdapter {
    /*//////////////////////////////////////////////////////////////
                              ERRORS
    //////////////////////////////////////////////////////////////*/

    error AaveV3Adapter__InvalidAavePoolAddressesProvider();
    error AaveV3Adapter__IncorrectWithdrawAmount();
    error AaveV3Adapter__NothingToWithdraw();

    /*//////////////////////////////////////////////////////////////
                            TYPE DECLARATIONS
    //////////////////////////////////////////////////////////////*/

    using SafeERC20 for IERC20;
    using WadRayMath for uint256;

    /// @dev The interface of the Aave V3 poolAddressProvider contract
    IPoolAddressesProvider private immutable i_aavePoolAddressesProvider;

    /*/////////////////////////////////////////////////////////
                            EVENTS
    /////////////////////////////////////////////////////////*/

    event Deposited(address indexed token, uint256 amount, uint256 shares);
    event Withdrawn(address indexed token, uint256 shares, uint256 amount);

    /*/////////////////////////////////////////////////////////
                            CONSTRUCTOR
    /////////////////////////////////////////////////////////*/

    constructor(
        address _aavePoolAddressesProvider /*,address _yieldAggregator*/
    ) {
        if (_aavePoolAddressesProvider == address(0)) revert AaveV3Adapter__InvalidAavePoolAddressesProvider();
        i_aavePoolAddressesProvider = IPoolAddressesProvider(_aavePoolAddressesProvider);
    }

    /*//////////////////////////////////////////////////////////////
                        EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Deposits tokens into Aave V3
     * @dev Key improvements:
     *      - Gets Pool address dynamically via AddressesProvider
     *      - Gets aToken address automatically via getReserveData()
     *      - No manual mapping needed!
     * @param token The underlying token to deposit (e.g., USDC)
     * @param amount Amount of tokens to deposit
     * @return shares Amount of aTokens received
     */
    function deposit(address token, uint256 amount) external returns (uint256 shares) {
        // STEP 1: Get the current Pool address (handles upgrades)
        address pool = _getAavePoolAddress();

        // STEP 2: Get aToken address dynamically from Aave
        address aToken = _getATokenAddress(token);

        // STEP 3: Pull tokens from YieldAggregator (msg.sender) to this adapter
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        // STEP 4: Check aToken balance BEFORE supply
        uint256 balanceBeforeSupply = IAToken(aToken).scaledBalanceOf(address(this));

        // STEP 5: Approve Pool to spend the tokens
        IERC20(token).forceApprove(pool, amount);

        // STEP 6: Deposit tokens into Aave Pool
        IPool(pool).supply(token, amount, address(this), 0);

        // STEP 7: Check aToken balance AFTER supply
        uint256 balanceAfterSupply = IAToken(aToken).scaledBalanceOf(address(this));

        // STEP 8: Calculate shares received (aTokens minted)
        shares = balanceAfterSupply - balanceBeforeSupply;

        emit Deposited(token, amount, shares);

        return shares;
    }

    /**
     * @notice Withdraws tokens from Aave V3
     * @dev Includes safety check to ensure withdrawn amount matches requested
     * @param token The underlying token to withdraw
     * @param shares Amount of aTokens to burn
     * @return amount Amount of underlying tokens received
     */
    function withdraw(address token, uint256 shares) external returns (uint256 amount) {
        // STEP 1: Get the current Pool address
        address pool = _getAavePoolAddress();

        // Convert THIS user's scaled shares → their underlying token amount
        // This is the only amount we have the right to withdraw
        uint256 liquidityIndex = IPool(pool).getReserveNormalizedIncome(token);
        uint256 underlyingAmount = WadRayMath.rayMul(shares, liquidityIndex);

        // STEP 2: Check adapter's underlying token balance BEFORE withdrawal
        uint256 balanceBeforeWithdrawal = IERC20(token).balanceOf(address(this));

        // STEP 3: Withdraw from Aave
        // This will:
        // - Burn the equivalent aTokens (roughly amountToWithdraw worth)
        // - Transfer amountToWithdraw underlying tokens to this adapter
        // - Return the actual amount withdrawn
        uint256 actualWithdrawn = IPool(pool).withdraw(token, underlyingAmount, address(this));

        // STEP 4: Safety check - ensure we got what we asked for
        // This protects against partial withdrawals or unexpected protocol behavior
        // if (actualWithdrawn != shares) {
        //     revert AaveV3Adapter__IncorrectWithdrawAmount();
        // }

        // STEP 5: Check adapter's underlying token balance AFTER withdrawal
        uint256 balanceAfterWithdrawal = IERC20(token).balanceOf(address(this));

        // Calculate actual amount received (should equal actualWithdrawn)
        amount = balanceAfterWithdrawal - balanceBeforeWithdrawal;

        if (amount != actualWithdrawn) {
            revert AaveV3Adapter__IncorrectWithdrawAmount();
        }
        if (amount == 0) revert AaveV3Adapter__NothingToWithdraw();

        // STEP 6: Transfer underlying tokens back to YieldAggregator
        IERC20(token).safeTransfer(msg.sender, amount);

        emit Withdrawn(token, shares, amount);

        return amount;
    }

    function getShareValue(address token, uint256 shares) external returns (uint256) {
        // In Aave V3, aTokens are pegged 1:1 with the underlying asset
        // Therefore, the share value is equal to the number of shares
        address pool = _getAavePoolAddress();

        uint256 liquidityIndex = IPool(pool).getReserveNormalizedIncome(token);

        return shares.rayMul(liquidityIndex);
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Internal function to get aToken address from Aave
     * @dev Uses getReserveData() to fetch the aToken address dynamically
     *      This is better than manual mapping!
     * @param token The underlying token address
     * @return aToken The aToken address
     */
    function _getATokenAddress(address token) internal view returns (address aToken) {
        address pool = _getAavePoolAddress();

        // Get reserve data from Aave - this contains all token info
        DataTypes.ReserveData memory reserveData = IPool(pool).getReserveData(token);

        // Extract the aToken address
        aToken = reserveData.aTokenAddress;
    }

    /// @notice Gets the Aave V3 pool address
    /// @return aavePool The Aave V3 pool address
    function _getAavePoolAddress() internal view returns (address aavePool) {
        aavePool = i_aavePoolAddressesProvider.getPool();
    }

    /*//////////////////////////////////////////////////////////////
                    EXTERNAL VIEW & PURE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    // returns the total balance of shares the adapter has in Aave
    function getBalance(address token) external view returns (uint256 balance) {
        address aToken = _getATokenAddress(token);
        balance = IERC20(aToken).balanceOf(address(this));
    }

    /**
     * @notice Gets the PoolAddressesProvider address
     * @dev This is the immutable registry address that never changes
     * @return The PoolAddressesProvider contract address
     */
    function getPoolAddressesProvider() external view returns (address) {
        return address(i_aavePoolAddressesProvider);
    }
}
