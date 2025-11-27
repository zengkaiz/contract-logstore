# contract-logstore

```markdown
# LogStore Smart Contract (Solidity + Hardhat)

本仓库为 Web3 作业的 **智能合约工程**，提供链上日志写入能力。  
前端会将日志信息进行加密，合约负责接收字符串并 emit 日志事件。

---

# 📌 合约功能说明

### ✔ 1. writeLog(string message)
- 记录日志到链上
- message 为**前端加密后的密文**
- 通过事件 LogRecorded 写出

### ✔ 2. TheGraph 监听事件
- TheGraph 会同步 LogRecorded
- 前端通过 GraphQL 查询事件日志

---

# 📦 LogStore.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract LogStore {
    event LogRecorded(address indexed sender, string message, uint256 timestamp);

    function writeLog(string calldata message) public {
        emit LogRecorded(msg.sender, message, block.timestamp);
    }
}
```
# 🛠️ 技术栈

Hardhat

Solidity 0.8.x

Alchemy/Infura RPC（推荐使用 Infura）

Ethers.js（部署使用）

# 目录结构
contracts/
  LogStore.sol
scripts/
  deploy.ts
artifacts/
hardhat.config.ts

# 部署步骤

npm install
npx hardhat run scripts/deploy.ts --network sepolia
部署成功后会输出类似：
LogStore deployed at: 0xAbC123.....

将此地址同步到（重要）：

frontend .env
subgraph subgraph.yaml


# 整体功能

| 作业要求            | 状态 |
| --------------- | -- |
| 使用 Hardhat 开发合约 | ✔  |
| 合约记录日志（event）   | ✔  |
| 部署到测试网（Sepolia） | ✔  |
| 前端合约交互          | ✔  |
| Subgraph 监听事件   | ✔  |


# 注意事项
建议使用 Infura 进行部署，更稳定

部署需要设置 SEPOLIA_PRIVATE_KEY 环境变量

合约不能实现解密逻辑（加密在前端）


# RedPacket
1. 新增一个红包合约
2. 支持发随机红包（传入红包金额，红包个数）
3. 支持随机抢红包，每个只能抢一次

得到：0xb41Cb0f468878Bd64B67e69Ea9cFad76bf570c6A