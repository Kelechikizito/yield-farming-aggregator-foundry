// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title IComet
 * @author Kelechi Kizito Ugwu
 * @notice A mimimalistic IComet Interface
 * @dev The compiler version discrepancy between the adapter and the Comet contract necessitated the creation of this interface.
 */
interface IComet {
    function supply(address asset, uint256 amount) external;
    function withdraw(address asset, uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
    // function claim(address comet, address source, bool shouldAccrue) external;
    // function getAssetInfo(uint8 i) external view returns (AssetInfo memory);
}
