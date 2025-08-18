pragma solidity ^0.8.21;

contract Casino {
    address public owner;
    uint256 public minimumBet;
    uint256 public totalBet;
    uint256 public numberOfBets;
    uint256 public maxAmountOfBets = 100;
    address[] public players;

    receive() external payable {}
    fallback() external payable {}

    struct Player {
        uint256 amountBet;
        uint256 numberSelected;
    }

    mapping(address => Player) public playerInfo;

    constructor(uint256 _minimumBet) {
        owner = msg.sender;
        if(_minimumBet != 0 ) minimumBet = _minimumBet;
    }

    function checkPlayerExists(address player) public view returns(bool){
        for(uint256 i = 0; i < players.length; i++){
            if(players[i] == player) return true;
        }
        return false;
    }

    function bet(uint256 numberSelected) public payable {
        require(!checkPlayerExists(msg.sender), "Player already exists");
        require(numberSelected >= 1 && numberSelected <= 10, "Number out of range");
        require(msg.value >= minimumBet, "Bet too low");
        require(players.length < maxAmountOfBets, "Max bets reached");

        playerInfo[msg.sender].amountBet = msg.value;
        playerInfo[msg.sender].numberSelected = numberSelected;
        numberOfBets++;
        players.push(msg.sender);
        totalBet += msg.value;
    }

    function generateNumberWinner() external {
        uint256 numberGenerated = uint256(keccak256(abi.encodePacked(block.timestamp, blockhash(block.number - 1), players.length))) % 10 + 1;
        distributePrizes(numberGenerated);
        distributePrizes(numberGenerated);
    }

    function distributePrizes(uint256 numberWinner) public {
        require(msg.sender == owner, "Only owner can distribute prizes");
        address[] memory winners = new address[](players.length);
        uint256 count = 0;

        for(uint256 i = 0; i < players.length; i++){
            address playerAddress = players[i];
            if(playerInfo[playerAddress].numberSelected == numberWinner){
                winners[count] = playerAddress;
                count++;
            }
            delete playerInfo[playerAddress];
        }

        players = new address[](0);

        if(count == 0){
            totalBet = 0;
            return;
        }

        uint256 winnerEtherAmount = totalBet / count;

        for(uint256 j = 0; j < count; j++){
            if(winners[j] != address(0)){
                (bool sent, ) = payable(winners[j]).call{value: winnerEtherAmount}("");
                require(sent, "Transfer failed");
            }
        }

        totalBet = 0;
        numberOfBets = 0;
    }
}