//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";



contract Casino is Ownable, ReentrancyGuard, VRFConsumerBase {

    address public gameToken = 0xC68e83a305b0FaD69E264A1769a0A070F190D2d6;

    address public constant VRF_COORDINATOR = 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B;
    address public constant LINK_TOKEN = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709;
    bytes32 public KEY_HASH = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
    uint256 public LINK_FEE = 0.1 ether;

    uint constant MAX_MODULO = 100;

    uint constant MAX_MASK_MODULO = 40;

    uint constant MAX_BET_MASK = 2 ** MAX_MASK_MODULO;


    uint public minBetAmount = 2 ether;
    uint public maxBetAmount = 10000 ether;

    struct Bet {
        uint amount;
        uint8 modulo;
        uint8 rollUnder;
        uint40 mask;
        uint placeBlockNumber;
        address gambler;
        bool isSettled;
        uint outcome;
        uint winAmount;
    }

    Bet[] public bets;

    mapping(bytes32 => uint) public betMap;

    uint public rewardPct = 20;

    uint public houseProfit;

    event BetPlaced (
        uint indexed betId,
        address indexed gambler,
        uint amount,
        uint8 indexed modulo,
        uint8 rollUnder,
        uint40 mask
    );
    event BetSettled (
        uint indexed betId,
        address indexed gambler,
        uint amount,
        uint8 indexed modulo,
        uint8 rollUnder,
        uint40 mask,
        uint outcome,
        uint winAmount,
        uint rollReward
    );

    event BetRefunded (
        uint indexed betId,
        address indexed gambler,
        uint amount
    );

    constructor() VRFConsumerBase(VRF_COORDINATOR, LINK_TOKEN) {}

    function placeBet(uint256 amount, uint256 betMask, uint256 modulo, address referrer) external nonReentrant {
        require(LINK.balanceOf(address(this)) >= LINK_FEE, "Insufficient link balance");
        require(modulo > 1 && modulo <= MAX_MODULO, "Modulo not within range");
        require(amount >= minBetAmount && amount <= maxBetAmount, "Bet amount not within range");
        require(betMask > 0 && betMask < MAX_BET_MASK, "Mask not within range");

        IERC20(gameToken).transferFrom(msg.sender, address(this), amount);

        uint256 rollUnder;
        uint256 mask;

    }

    function settleBet(bytes32 requestId, uint256 randomNumber) internal nonReentrant {
        uint betId = betMap[requestId];
        Bet storage bet = bets[betId];
        uint256 amount = bet.amount;

        require(amount > 0, "Bet does not exist");
        require(bet.isSettled == false, "Bet is settled already");

        uint256 modulo = bet.modulo;
        uint256 rollUnder = bet.rollUnder;
        address gambler = bet.gambler;

        uint256 outcome = randomNumber % modulo;

        uint256 possibleWinAmount = getWinAmount(amount, modulo, rollUnder);

        uint256 rollReward = getRollReward(amount, modulo, rollUnder);

        uint256 winAmount = 0;

        
    }


}
