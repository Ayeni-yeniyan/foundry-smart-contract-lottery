// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";

import {Raffle} from "../../src/Raffle.sol";

/// Test contract for Raffle contract
contract RaffleTest is Test {
    Raffle raffle;
    uint256 constant ENTRANCE_AMOUNT = 0.001 ether;
    uint256 constant FAILED_AMOUNT = 0.0001 ether;

    function setUp() external {
        raffle = new Raffle(ENTRANCE_AMOUNT);
    }

    /// SHOULD revert if sent value is less than entrance amount
    function testEnterValueAgainstEntraceAmount() public {
        vm.expectRevert();
        raffle.enterRaffle{value: FAILED_AMOUNT}();
    }
}
