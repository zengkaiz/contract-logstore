// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RedPacket {
    struct RedPacketInfo {
        address creator;           // 红包创建者
        uint256 totalAmount;       // 红包总金额
        uint256 totalCount;        // 红包总个数
        uint256 remainingCount;    // 剩余红包个数
        uint256 remainingAmount;   // 剩余金额
        uint256 minAmount;         // 最小红包金额（防止为0）
        bool exists;               // 红包是否存在
    }

    // 红包ID -> 红包信息
    mapping(uint256 => RedPacketInfo) public redPackets;

    // 红包ID -> 地址 -> 是否已领取
    mapping(uint256 => mapping(address => bool)) public hasClaimed;

    // 红包ID -> 地址 -> 领取的金额
    mapping(uint256 => mapping(address => uint256)) public claimedAmount;

    // 红包计数器
    uint256 public redPacketCount;

    // 事件
    event RedPacketCreated(
        uint256 indexed redPacketId,
        address indexed creator,
        uint256 totalAmount,
        uint256 count
    );

    event RedPacketClaimed(
        uint256 indexed redPacketId,
        address indexed claimer,
        uint256 amount
    );

    /**
     * @dev 创建红包
     * @param count 红包个数
     */
    function createRedPacket(uint256 count) external payable returns (uint256) {
        require(msg.value > 0, "RedPacket: amount must be greater than 0");
        require(count > 0, "RedPacket: count must be greater than 0");
        require(msg.value >= count, "RedPacket: amount too small for count");

        uint256 redPacketId = redPacketCount++;

        // 计算最小红包金额（总金额的1%，最少1 wei）
        uint256 minAmount = msg.value / 100;
        if (minAmount == 0) {
            minAmount = 1;
        }

        redPackets[redPacketId] = RedPacketInfo({
            creator: msg.sender,
            totalAmount: msg.value,
            totalCount: count,
            remainingCount: count,
            remainingAmount: msg.value,
            minAmount: minAmount,
            exists: true
        });

        emit RedPacketCreated(redPacketId, msg.sender, msg.value, count);

        return redPacketId;
    }

    /**
     * @dev 抢红包（随机金额）
     * @param redPacketId 红包ID
     */
    function claimRedPacket(uint256 redPacketId) external {
        RedPacketInfo storage redPacket = redPackets[redPacketId];

        require(redPacket.exists, "RedPacket: red packet does not exist");
        require(redPacket.remainingCount > 0, "RedPacket: no red packets left");
        require(!hasClaimed[redPacketId][msg.sender], "RedPacket: already claimed");

        // 标记为已领取
        hasClaimed[redPacketId][msg.sender] = true;

        uint256 amount;

        // 如果是最后一个红包，直接领取剩余所有金额
        if (redPacket.remainingCount == 1) {
            amount = redPacket.remainingAmount;
        } else {
            // 随机分配金额
            // 计算最大可领取金额：剩余金额的2倍除以剩余个数
            uint256 maxAmount = (redPacket.remainingAmount * 2) / redPacket.remainingCount;

            // 生成伪随机数
            uint256 random = uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.prevrandao,
                        msg.sender,
                        redPacket.remainingAmount,
                        redPacket.remainingCount
                    )
                )
            );

            // 计算随机金额：在 minAmount 到 maxAmount 之间
            amount = redPacket.minAmount + (random % (maxAmount - redPacket.minAmount + 1));

            // 确保不超过剩余金额
            if (amount > redPacket.remainingAmount) {
                amount = redPacket.remainingAmount;
            }
        }

        // 更新红包状态
        redPacket.remainingCount--;
        redPacket.remainingAmount -= amount;
        claimedAmount[redPacketId][msg.sender] = amount;

        // 转账
        payable(msg.sender).transfer(amount);

        emit RedPacketClaimed(redPacketId, msg.sender, amount);
    }

    /**
     * @dev 查询红包信息
     * @param redPacketId 红包ID
     */
    function getRedPacketInfo(uint256 redPacketId) external view returns (
        address creator,
        uint256 totalAmount,
        uint256 totalCount,
        uint256 remainingCount,
        uint256 remainingAmount
    ) {
        RedPacketInfo memory redPacket = redPackets[redPacketId];
        require(redPacket.exists, "RedPacket: red packet does not exist");

        return (
            redPacket.creator,
            redPacket.totalAmount,
            redPacket.totalCount,
            redPacket.remainingCount,
            redPacket.remainingAmount
        );
    }

    /**
     * @dev 查询用户是否已领取
     * @param redPacketId 红包ID
     * @param user 用户地址
     */
    function hasUserClaimed(uint256 redPacketId, address user) external view returns (bool) {
        return hasClaimed[redPacketId][user];
    }

    /**
     * @dev 查询用户领取的金额
     * @param redPacketId 红包ID
     * @param user 用户地址
     */
    function getUserClaimedAmount(uint256 redPacketId, address user) external view returns (uint256) {
        return claimedAmount[redPacketId][user];
    }
}
