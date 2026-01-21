// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// Layout of the contract file:
// version
// imports
// interfaces, libraries, contract
// errors

// Inside Contract:
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private

// view & pure functions

/**
 * @title StrategyManager
 * @author Kelechi Kizito Ugwu
 * @notice This contract manages and optimizes investment strategies for the Yield Aggregator Contract. In simpler terms, it Handles the logic for comparing yields and switching strategies.
 * @dev
 */
contract StrategyManager {
    /*//////////////////////////////////////////////////////////////
                              ERRORS
    //////////////////////////////////////////////////////////////*/
    error StrategyManager__InvalidTokenAddress();

    /*////////////////////////////////////////////////////////////
           STATE VARIABLES
    /////////////////////////////////////////////////////////////*/

    string[] private s_supportedProtocols;

    /*//////////////////////////////////////////////////////////////
                             MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
                            EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function findBestYield(address token, uint256 amount)
        external
        view
        returns (
            string memory protocol /*,uint256 apy*/
        )
    {
        _findBestYield(token, amount);
    }

    function calculateSwitchBenefit(address user, uint256 positionIndex, string memory newProtocol)
        external
        view
        returns (int256 netBenefit)
    {
        _calculateSwitchBenefit(user, positionIndex, newProtocol);
    }

    function isProtocolSafe(string memory protocol) external view returns (bool) {
        _isProtocolSafe(protocol);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    // Compare APYs across ALL supported protocols and return the one with the highest yield.
    function _findBestYield(address token, uint256 amount)
        internal
        view
        returns (
            string memory protocol /*,uint256 apy*/
        )
    {
        // Logic to compare yields across protocols
        // This code might not need to return the apy, but that would be worked on later

        // CHECKS
        if (token == address(0)) {
            revert StrategyManager__InvalidTokenAddress();
        }

        // LOGIC TO FIND BEST YIELD
    }

    function _calculateSwitchBenefit(address user, uint256 positionIndex, string memory newProtocol)
        internal
        view
        returns (int256 netBenefit)
    {
        // Logic to calculate the net benefit of switching strategies
    }

    function _isProtocolSafe(string memory protocol) internal view returns (bool) {}
}
