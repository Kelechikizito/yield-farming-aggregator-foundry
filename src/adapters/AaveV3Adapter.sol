// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IProtocolAdapter} from "src/interfaces/IProtocolAdapter.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
/// @dev This interface contract is the interface for the main user-facing contract for aave protocol - This is like Comet for Compound
import {IPool} from "@aave/core-v3/contracts/interfaces/IPool.sol";

/**
 * @title AaveV3Adapter
 * @author Kelechi Kizito Ugwu
 * @notice Adapter contract for interacting with the Aave V3 protocol.
 * @dev
 */
// note: The aave pool contract is the main entry point into the AAVE protocol
abstract contract AaveV3Adapter is IProtocolAdapter {
    error AaveV3Adapter__InvalidAavePoolAddress();

    using SafeERC20 for IERC20;

    /// @dev The interface of the Aave V3 pool
    IPool private immutable i_aavePool;

    constructor(
        address _aavePool /*,address _yieldAggregator*/
    ) {
        if (_aavePool == address(0)) revert AaveV3Adapter__InvalidAavePoolAddress();
        i_aavePool = IPool(_aavePool);
    }

    function deposit(uint256 amount, address token) external returns (uint256 shares) {
        //         function supply(
        //     address asset,
        //     uint256 amount,
        //     address onBehalfOf,
        //     uint16 referralCode
        // ) public virtual override {}
    }

    function withdraw(address token, uint256 shares) external returns (uint256 amount) {}
}
