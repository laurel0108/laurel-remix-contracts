const XYZCoin = artifacts.require("XYZCoin");
// 引入 truffle-assertions 库
const truffleAssert = require("truffle-assertions");

contract("XYZCoin", async (accounts) => {
  let xyzCoin;

  // 在所有测试前部署合约
  before(async () => {
    xyzCoin = await XYZCoin.deployed();
  });

  // 测试用例 1：余额不足时转账回滚（Insufficient balance）
  it("should revert on insufficient balance", async () => {
    // accounts[1] 初始余额为 0，尝试转 1 个代币
    await truffleAssert.reverts(
      xyzCoin.transfer(accounts[2], 1, { from: accounts[1] }),
      "Insufficient balance" // 匹配合约中抛出的错误信息
    );
  });

  // 测试用例 2：未授权账户 transferFrom 回滚
  it("should revert transferFrom from unauthorized account", async () => {
    // accounts[1] 未被授权，尝试转 accounts[0] 的代币
    await truffleAssert.reverts(
      xyzCoin.transferFrom(accounts[0], accounts[2], 1, { from: accounts[1] }),
      "Allowance exceeded" // 匹配合约中抛出的错误信息
    );
  });

  // 测试用例 3：transfer() 触发 Transfer 事件（含 0 值转账）
  it("transfer() should emit Transfer event", async () => {
    // 0 值转账测试
    const result = await xyzCoin.transfer(accounts[1], 0, { from: accounts[0] });
    truffleAssert.eventEmitted(result, "Transfer", (event) => {
      return (
        event._from === accounts[0] &&
        event._to === accounts[1] &&
        event._value.toString() === "0"
      );
    });
  });

  // 测试用例 4：transferFrom() 触发 Transfer 事件（含 0 值转账）
  it("transferFrom() should emit Transfer event", async () => {
    // 先授权 accounts[1] 可转 0 个代币
    await xyzCoin.approve(accounts[1], 0, { from: accounts[0] });
    // 执行 transferFrom（0 值）
    const result = await xyzCoin.transferFrom(
      accounts[0],
      accounts[2],
      0,
      { from: accounts[1] }
    );
    truffleAssert.eventEmitted(result, "Transfer", (event) => {
      return (
        event._from === accounts[0] &&
        event._to === accounts[2] &&
        event._value.toString() === "0"
      );
    });
  });

  // 测试用例 5：approve() 触发 Approval 事件
  it("approve() should emit Approval event", async () => {
    const result = await xyzCoin.approve(accounts[1], 5, { from: accounts[0] });
    truffleAssert.eventEmitted(result, "Approval", (event) => {
      return (
        event._owner === accounts[0] &&
        event._spender === accounts[1] &&
        event._value.toString() === "5"
      );
    });
  });
});