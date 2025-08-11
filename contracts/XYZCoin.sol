pragma solidity 0.5.1;

import "./ERC20.sol";

contract XYZCoin is ERC20 {
    // 全局变量
    string public name = "XYZCoin";       // 代币名称
    string public symbol = "XYZ";         // 代币符号
    uint8 public decimals = 0;            // 小数位数（题目要求为 0）
    uint256 public totalSupply = 1000;    // 总供应量

    //  balances：记录每个地址的代币余额
    mapping(address => uint256) public balances;
    //  allowed：记录授权额度（_owner 允许 _spender 花费的代币数量）
    mapping(address => mapping(address => uint256)) public allowed;

    // 构造函数：初始化部署者余额
    constructor() public {
        balances[msg.sender] = totalSupply; // 把所有代币发给部署者
    }

    // ---- 实现 ERC20 接口函数 ----
    function totalSupply() external view returns (uint256) {
        return totalSupply;
    }

    function balanceOf(address _owner) external view returns (uint256) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) external returns (bool) {
        require(balances[msg.sender] >= _value, "Insufficient balance");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) external returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool) {
        require(balances[_from] >= _value, "From address balance insufficient");
        require(allowed[_from][msg.sender] >= _value, "Allowance exceeded");
        
        balances[_from] -= _value;
        balances[_to] += _value;
        allowed[_from][msg.sender] -= _value;
        
        emit Transfer(_from, _to, _value);
        return true;
    }

    function allowance(address _owner, address _spender) external view returns (uint256) {
        return allowed[_owner][_spender];
    }
}