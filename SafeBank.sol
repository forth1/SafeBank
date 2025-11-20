// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// @title 一个简单但相对安全的银行合约
/// @notice 支持存钱、取钱，并做了防重入处理
contract SafeBank {
    // 每个地址在银行里的余额（单位：wei）
    mapping(address => uint256) public balances;

    // 简单的防重入锁
    bool private locked;

    // 存钱 / 取钱事件，方便你在 Logs 里观察
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    // 防重入修饰符
    modifier nonReentrant() {
        require(!locked, "Reentrancy detected");
        locked = true;
        _;
        locked = false;
    }

    /// @notice 存钱：往合约里转 ETH
    function deposit() external payable {
        // 1. 参数 & 状态检查（require）
        require(msg.value > 0, "Deposit must > 0");

        // 2. 更新状态（Effect）
        balances[msg.sender] += msg.value;

        // 3. 触发事件（方便前端 & 日志查看）
        emit Deposit(msg.sender, msg.value);
    }

    /// @notice 取钱：从合约取出指定数量 ETH
    /// @param amount 要取出的金额（单位：wei）
    function withdraw(uint256 amount) external nonReentrant {
        // 1. 检查
        require(amount > 0, "Amount must > 0");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // 2. 先更新余额（Effect）
        balances[msg.sender] -= amount;

        // 3. 再转账（Interaction）
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "ETH transfer failed");

        emit Withdraw(msg.sender, amount);
    }

    /// @notice 查询自己在银行里的余额（单位：wei）
    function getMyBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

    /// @notice 查询整个银行合约里有多少 ETH
    function getBankBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
