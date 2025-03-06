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
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * @title A sample raffle contract for learning purposes
 * @author Ayeni Samuel
 * @notice This contract is a learning material to create a sample raffle
 * @dev Implements ChainLink VRFv2.5
 *
 */

contract Raffle is VRFConsumerBaseV2Plus {
    /* Errors */
    error Raffle__SendMoreEthToEnterRaffle();
    error Raffle__TransferFailed();
    error Raffle__RaffleNotOpen();
    error Raffle__UpkeepNotNeeded(uint256 balance, uint256 playersLength, uint256 raffleState);

    /* Enums */
    enum RaffleState {
        OPEN,
        CALCULATING
    }

    /* Variables */

    uint16 private constant REQUEST_CONFIRMATION = 3;
    uint32 private constant NUM_WORDS = 3;
    uint256 private immutable i_entranceFee;
    // @dev duration of lottery
    uint256 private immutable i_interval;
    bytes32 private immutable i_keyhash;
    uint256 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    address payable[] private s_players;
    address private s_recentWinner;
    uint256 private s_lastTimeStamp;
    RaffleState private s_raffleState;

    /* Events */
    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed winner);
    event RequestedTaffleWinner(uint256 indexed requestId);

    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint256 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        i_keyhash = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;

        s_lastTimeStamp = block.timestamp;
        s_raffleState = RaffleState.OPEN;
    }

    /// Enter the address into the Raffle contract
    // TODO: write test ensuring that revert is called when the entranceFee is lower than the allowed entrance fee
    function enterRaffle() external payable {
        if (msg.value < i_entranceFee) {
            revert Raffle__SendMoreEthToEnterRaffle();
        }
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__RaffleNotOpen();
        }
        s_players.push(payable(msg.sender));
        // Makes front end indexing faster
        emit RaffleEntered(msg.sender);
    }


    function checkUpkeep(bytes memory /** v */) public view  returns (
        bool upkeepNeeded,bytes memory /* PerformData */)  {
         bool timeHasPassed=(block.timestamp - s_lastTimeStamp) > i_interval;
         bool isOpen=s_raffleState==RaffleState.OPEN;
         bool hasBalance =address(this).balance>0;
         bool hasPlayers =s_players.length>0;
        upkeepNeeded=timeHasPassed&&isOpen&&hasBalance&&hasPlayers;
         return (upkeepNeeded,"");
    }

    /// Pick the winner of the raffle and send the winner the amount won
    function performUpkeep(bytes calldata /** v */ x) external {
        (bool upkeedNeeded,)= checkUpkeep("");
        if (!upkeedNeeded) {
            revert Raffle__UpkeepNotNeeded(address(this).balance,s_players.length,uint256(s_raffleState));
        }
        s_raffleState = RaffleState.CALCULATING;
        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient
            .RandomWordsRequest({
                keyHash: i_keyhash, // Replace with actual keyHash
                subId: i_subscriptionId, // Replace with actual subscription ID
                requestConfirmations: REQUEST_CONFIRMATION, // Replace with actual minimum request confirmations
                callbackGasLimit: i_callbackGasLimit, // Replace with actual callback gas limit
                numWords: NUM_WORDS, // Replace with actual number of words
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            });
        uint256 requestId = s_vrfCoordinator.requestRandomWords(request);
        emit RequestedTaffleWinner(requestId);
        // Get random number from chainlink vrf
    }

    /// Get the entrance fee to participate in the raffle
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    } /// Get the entrance fee to participate in the raffle

    function getPlayersNumber() external view returns (uint256) {
        return s_players.length;
    } 
    
    function getPlayersAtIndex(uint256 index) external view returns (address) {
        return s_players[index];
    }

    function getRaffleInterval() external view returns (uint256) {
        return i_interval;
    }
    function getRaffleState() external view returns (RaffleState) {
        return s_raffleState;
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal virtual override {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        s_raffleState = RaffleState.OPEN;
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
        emit WinnerPicked(s_recentWinner);
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransferFailed();
        }
    }
}

// CEIs Checks, Effects and Interactions
