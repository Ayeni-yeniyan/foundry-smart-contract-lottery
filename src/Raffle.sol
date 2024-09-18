// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
 * @title A sample raffle contract for learning purposes
 * @author Ayeni Samuel
 * @notice This contract is a learning material to create a sample raffle
 * @dev Implements ChainLink VRFv2.5
 *
 */

contract Raffle {
    /* Errors */
    error Raffle__SendMoreEthToEnterRaffle();

    /* Variables */
    uint256 private immutable i_entranceFee;
    address payable[] private s_players;

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    /// Enter the address into the Raffle contract
    // TODO: write test ensuring that revert is called when the entranceFee is lower than the allowed entrance fee
    function enterRaffle() public payable {
        if (msg.value < i_entranceFee) {
            revert Raffle__SendMoreEthToEnterRaffle();
        }
    }

    /// Pick the winner of the raffle and send the winner the amount won
    // TODO: write test ensuring that the winner is selected at random
    // TODO: write test ensuring that the selected winner is paid all the raffle amount
    function pickWinner() public {}

    /// Get the entrance fee to participate in the raffle
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    } /// Get the entrance fee to participate in the raffle

    function getPlayersNumber() external view returns (uint256) {
        return s_players.length;
    }
}
