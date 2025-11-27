// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

/**
 * @title LogStore
 * @dev 去中心化日志存储合约
 * @notice 本合约用于将加密的日志内容存储到区块链上
 *
 * 功能特点：
 * - 仅通过事件存储数据，不占用合约存储空间，节省 gas
 * - 支持加密内容存储，保护用户隐私
 * - 通过 The Graph 等索引服务可以高效查询历史日志
 * - 每条日志都关联发送者地址和时间戳
 */
contract LogStore {
  /**
   * @dev 日志保存事件
   * @notice 当用户保存日志时触发此事件，事件数据会被永久记录在区块链上
   *
   * @param sender 日志发送者的地址（indexed，可用于过滤查询）
   * @param encryptedContent 加密后的日志内容（前端使用密钥加密）
   * @param timestamp 日志保存的时间戳（区块时间）
   *
   */
  event LogSaved(address indexed sender, string encryptedContent, uint256 timestamp);

  /**
   * @dev 保存加密日志
   * @notice 用户调用此函数保存加密的日志内容到区块链
   *
   * @param encryptedContent 加密后的日志内容字符串
   *
   * 工作流程：
   * 1. 前端使用密钥（如 AES-256）加密日志内容
   * 2. 调用此函数，传入加密后的字符串
   * 3. 合约触发 LogSaved 事件，将数据记录到区块链
   * 4. The Graph 索引此事件，建立可查询的数据库
   * 5. 前端通过 The Graph 查询日志，使用密钥解密
   *
   * Gas 优化：
   * - 使用 calldata 而非 memory，节省 gas
   * - 仅触发事件不修改状态，成本低
   * - 使用 external 而非 public，外部调用更高效
   *
   * 安全性：
   * - 任何人都可以调用此函数
   * - 加密内容由前端负责，合约不验证格式
   * - 发送者地址由 msg.sender 自动获取，无法伪造
   */
  function saveLog(string calldata encryptedContent) external {
    // 触发日志保存事件，将数据永久记录到区块链事件日志中
    // msg.sender: 当前调用者的地址
    // encryptedContent: 前端加密后的日志内容
    // block.timestamp: 当前区块的时间戳
    emit LogSaved(msg.sender, encryptedContent, block.timestamp);
  }
}