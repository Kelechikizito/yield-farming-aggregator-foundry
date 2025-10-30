// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/// @title IProtocolAdapter
/// @author Kelechi Kizito Ugwu
/// @notice This interface defines the standard functions for protocol adapters used by the Yield Aggregator contract to interact with various DeFi protocols.
/// @dev
interface IProtocolAdapter {
    /*//////////////////////////////////////////////////////////////
                            EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function deposit(uint256 amount, address token) external returns (uint256 shares);
    function withdraw(uint256 shares, address token) external returns (uint256 amount);
    function getCurrentAPY(address token) external view returns (uint256);
    function getPositionValue(uint256 shares, address token) external view returns (uint256);
    function getAccruedRewards(address user, uint256 shares) external view returns (uint256);
    function claimAndCompound(uint256 shares) external returns (uint256 newShares);
    function getTVL(address token) external view returns (uint256);
}

