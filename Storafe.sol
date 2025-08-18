pragma solidity ^0.8.21;

// 存储合约：专门管理Casino合约的关键数据
contract Storage {
    // 管理员地址（与Casino合约的owner保持一致）
    address public casinoOwner;
    
    // 历史开奖记录：开奖编号 → 开奖结果
    mapping(uint256 => uint256) public historyWinners;
    uint256 public historyCount; // 开奖总次数
    
    // 用户历史投注：用户地址 → 投注记录数组
    struct BetRecord {
        uint256 betAmount; // 投注金额
        uint256 numberSelected; // 选中数字
        uint256 round; // 所属开奖轮次
        bool isWinner; // 是否中奖
    }
    mapping(address => BetRecord[]) public userBetHistory;
    
    // 权限控制：仅Casino合约的owner可调用
    modifier onlyCasinoOwner() {
        require(msg.sender == casinoOwner, "Only casino owner can call");
        _;
    }
    
    // 初始化：绑定Casino合约的owner
    constructor(address _casinoOwner) {
        casinoOwner = _casinoOwner;
    }
    
    // 存储新的开奖结果
    function addWinnerRecord(uint256 winnerNumber) external onlyCasinoOwner {
        historyCount++;
        historyWinners[historyCount] = winnerNumber;
    }
    
    // 存储用户投注记录
    function addUserBet(
        address user,
        uint256 betAmount,
        uint256 numberSelected,
        bool isWinner
    ) external onlyCasinoOwner {
        userBetHistory[user].push(BetRecord({
            betAmount: betAmount,
            numberSelected: numberSelected,
            round: historyCount + 1, // 关联下一轮开奖（当前未开奖）
            isWinner: isWinner
        }));
    }
    
    // 查询用户投注记录数量
    function getUserBetCount(address user) external view returns (uint256) {
        return userBetHistory[user].length;
    }
    
    // 查询指定用户的第N条投注记录
    function getUserBetRecord(address user, uint256 index) external view returns (BetRecord memory) {
        require(index < userBetHistory[user].length, "Invalid index");
        return userBetHistory[user][index];
    }
}