// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IProtocolAdapter} from "src/interfaces/IProtocolAdapter.sol";

/**
 * @title AaveV3Adapter
 * @author Kelechi Kizito Ugwu
 * @notice Adapter contract for interacting with the Aave V3 protocol.
 * @dev
 */
contract AaveV3Adapter is IProtocolAdapter {
    function deposit(uint256 amount, address token) external returns (uint256 shares) {}
}
