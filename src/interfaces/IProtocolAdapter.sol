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
    function deposit(address token, uint256 amount) external returns (uint256 shares);
    function withdraw(address token, uint256 shares) external returns (uint256 amount);
    function getShareValue(address token, uint256 shares) external returns (uint256);
    // function getCurrentAPY(address token) external view returns (uint256);
    // function getAccruedRewards(address user, uint256 shares) external view returns (uint256);
    // function claimAndCompound(uint256 shares) external returns (uint256 newShares);
    // function getTVL(address token) external view returns (uint256);
}

