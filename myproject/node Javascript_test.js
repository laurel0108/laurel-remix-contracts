const { Web3 }= require('web3');

// 配置Infura连接信息（使用提供的API密钥）
const INFURA_PROJECT_ID = 'b64118c571c6466182a39a715b335385';
const INFURA_HTTPS = `https://mainnet.infura.io/v3/${INFURA_PROJECT_ID}`;

// 初始化Web3实例，连接到以太坊主网
const web3 = new Web3('https://mainnet.infura.io/v3/b64118c571c6466182a39a715b335385');

/**
 * 检查指定区块是否包含合约创建交易（接收者为null的交易）
 * @param {number} blockNumber - 要检查的区块号
 * @returns {Promise<boolean>} 存在合约创建交易则返回true，否则返回false
 */
async function hasContractCreationTx(blockNumber) {
  try {
    // 获取区块详情（第二个参数为true表示同时获取交易详情）
    const block = await web3.eth.getBlock(blockNumber, true);
    
    // 若区块不存在或无交易，直接返回false
    if (!block || !block.transactions || block.transactions.length === 0) {
      return false;
    }
    
    // 检查区块中是否有接收者为null的交易（合约创建交易）
    return block.transactions.some(tx => tx.to === null);
  } catch (error) {
    console.error(`检查区块${blockNumber}时出错:`, error.message);
    return false;
  }
}

/**
 * 查找包含第一笔合约创建交易的区块
 */
async function findFirstContractBlock() {
  try {
    // 获取最新区块号，作为搜索上限
    const latestBlock = await web3.eth.getBlockNumber();
    console.log(`开始搜索，当前最新区块: ${latestBlock}`);
    
    let low = 0;
    let high = latestBlock;
    let firstBlock = -1;
    
    // 使用二分查找高效定位目标区块
    while (low <= high) {
      const mid = Math.floor((low + high) / 2);
      console.log(`正在检查区块: ${mid}`);
      
      const hasCreation = await hasContractCreationTx(mid);
      
      if (hasCreation) {
        // 若当前区块有合约创建交易，尝试查找更早的区块
        firstBlock = mid;
        high = mid - 1;
      } else {
        // 若当前区块没有，搜索更晚的区块
        low = mid + 1;
      }
    }
    
    if (firstBlock !== -1) {
      console.log(`找到第一笔合约创建交易所在的区块: ${firstBlock}`);
    } else {
      console.log('未找到包含合约创建交易的区块');
    }
  } catch (error) {
    console.error('搜索过程出错:', error.message);
  }
}

// 执行搜索
findFirstContractBlock();

async function hasContractCreationTx(blockNumber) {
    try {
        let block = await web3.eth.getBlock(blockNumber, true);
        if (!block || !block.transactions || block.transactions.length === 0) {
            return false;
        }
        // 后续对 block 处理及返回逻辑...
    } catch (error) {
        console.error('获取区块信息出错:', error);
        return false; // 或者根据实际需求返回合适的错误标识等
    }
}