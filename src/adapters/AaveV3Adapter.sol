// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IProtocolAdapter} from "src/interfaces/IProtocolAdapter.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
/// @dev This interface contract is the interface for the main user-facing contract for aave protocol - This is like Comet for Compound
import {IPool} from "@aave/core-v3/contracts/interfaces/IPool.sol";
import {DataTypes} from "@aave/core-v3/contracts/protocol/libraries/types/DataTypes.sol";
import {IPoolAddressesProvider} from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";

/**
 * @title AaveV3Adapter
 * @author Kelechi Kizito Ugwu
 * @notice Adapter contract for interacting with the Aave V3 protocol.
 * @dev
 */
// note: The aave pool contract is the main entry point into the AAVE protocol
contract AaveV3Adapter is IProtocolAdapter {
    /*//////////////////////////////////////////////////////////////
                              ERRORS
    //////////////////////////////////////////////////////////////*/

    error AaveV3Adapter__InvalidAavePoolAddress();

    /*//////////////////////////////////////////////////////////////
                            TYPE DECLARATIONS
    //////////////////////////////////////////////////////////////*/

    using SafeERC20 for IERC20;

    /// @dev The interface of the Aave V3 poolAddressProvider contract
    IPoolAddressesProvider private immutable i_aavePoolAddressesProvider;

    /*/////////////////////////////////////////////////////////
                            CONSTRUCTOR
    /////////////////////////////////////////////////////////*/

    constructor(
        address _aavePoolAddressesProvider /*,address _yieldAggregator*/
    ) {
        if (_aavePoolAddressesProvider == address(0)) revert AaveV3Adapter__InvalidAavePoolAddress();
        i_aavePoolAddressesProvider = IPool(_aavePoolAddressesProvider);
    }

    /*//////////////////////////////////////////////////////////////
                        EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function deposit(address token, uint256 amount) external returns (uint256 shares) {
        i_aavePool.supply(token, amount, address(this), 0);
    }

    function withdraw(address token, uint256 shares) external returns (uint256 amount) {
        i_aavePool.withdraw(token, amount, address(this));
    }
}
