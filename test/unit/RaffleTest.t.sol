// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";

import {Raffle} from "src/Raffle.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {DeployRaffle} from "script/DeployRaffle.s.sol";

/// Test contract for Raffle contract
contract RaffleTest is Test {
    Raffle public raffle;
    HelperConfig public helperConfig;
    address public PLAYER = makeAddr("Player");
    uint256 constant PLAYER_STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, ) = deployer.deployContract();
    }
}
