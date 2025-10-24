// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface IStrategyManager {
    function findBestYield(address token, uint256 amount) external view returns (string memory protocol);
    function calculateSwitchBenefit(address user, uint256 positionIndex, string memory newProtocol)
        external
        view
        returns (int256 netBenefit);
    function isProtocolSafe(string memory protocol) external view returns (bool);
}
