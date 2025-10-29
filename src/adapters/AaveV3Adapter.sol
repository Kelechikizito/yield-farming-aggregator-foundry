// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IProtocolAdapter} from "src/interfaces/IProtocolAdapter.sol";

contract AaveV3Adapter is IProtocolAdapter {
    function deposit(uint256 amount, address token) external returns (uint256 shares) {}
}
