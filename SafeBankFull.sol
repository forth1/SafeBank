// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/// @title SafeBank - 带白名单、防重入、交易记录的安全银行合约
contract SafeBank {
    // ========= 状态变量 =========

    // 合约拥有者
    address public owner;

    // 防重入锁
    bool private locked;

    // 每个用户的存款余额（单位：wei）
    mapping(address => uint256) public balances;

    // 白名单：true 表示允许存取款
    mapping(address => bool) public whitelist;

    // ----- Lesson 5：数组 & 进阶 mapping -----

    // 存过钱的用户列表（每个地址只会被记录一次）
    address[] public depositors;
    mapping(address => bool) private hasDepositedBefore;

    // 交易记录
    struct TxRecord {
        address user;
        uint256 amount;
        bool isDeposit;     // true = 存款, false = 取款
        uint256 timestamp;
    }

    // 所有交易记录数组
    TxRecord[] public txHistory;

    // 每个用户对应的「交易记录下标列表」
    mapping(address => uint256[]) public userTxIds;

    // ========= 事件 =========

    event AddedToWhitelist(address account);
    event RemovedFromWhitelist(address account);
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    // ========= 构造函数 =========

    constructor() {
        owner = msg.sender;
        // 默认把 deploy 合约的钱包加到白名单
        whitelist[msg.sender] = true;
        emit AddedToWhitelist(msg.sender);
    }

    // ========= 修饰符 =========

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyWhitelist() {
        require(whitelist[msg.sender], "Not in whitelist");
        _;
    }

    modifier nonReentrant() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    // ========= 白名单管理 =========

    function addWhitelist(address account) external onlyOwner {
        require(account != address(0), "Zero address");
        require(!whitelist[account], "Already in whitelist");

        whitelist[account] = true;
        emit AddedToWhitelist(account);
    }

    function removeWhitelist(address account) external onlyOwner {
        require(whitelist[account], "Not in whitelist");

        whitelist[account] = false;
        emit RemovedFromWhitelist(account);
    }

    // ========= 存款 / 取款 =========

    /// @notice 白名单用户存款
    function deposit() external payable onlyWhitelist nonReentrant {
        require(msg.value > 0, "Deposit must > 0");

        // 1. 记录余额（Effect）
        balances[msg.sender] += msg.value;

        // 2. 第一次存款的用户，加入 depositors 数组
        if (!hasDepositedBefore[msg.sender]) {
            hasDepositedBefore[msg.sender] = true;
            depositors.push(msg.sender);
        }

        // 3. 记录交易
        uint256 txId = txHistory.length;
        txHistory.push(
            TxRecord({
                user: msg.sender,
                amount: msg.value,
                isDeposit: true,
                timestamp: block.timestamp
            })
        );
        userTxIds[msg.sender].push(txId);

        emit Deposit(msg.sender, msg.value);
    }

    /// @notice 白名单用户取款
    function withdraw(uint256 amount) external onlyWhitelist nonReentrant {
        require(amount > 0, "Amount must > 0");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // 1. 先扣减余额（Effect）
        balances[msg.sender] -= amount;

        // 2. 再转账（Interaction）
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "ETH transfer failed");

        // 3. 记录交易
        uint256 txId = txHistory.length;
        txHistory.push(
            TxRecord({
                user: msg.sender,
                amount: amount,
                isDeposit: false,
                timestamp: block.timestamp
            })
        );
        userTxIds[msg.sender].push(txId);

        emit Withdraw(msg.sender, amount);
    }

    // ========= 查询函数（余额相关） =========

    /// @notice 查看自己的银行余额（单位：wei）
    function getMyBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

    /// @notice 查看整个银行里有多少 ETH
    function getBankBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // ========= 查询函数（Lesson 5：数组 & 记录） =========

    /// @notice 返回存过钱的用户数量
    function getDepositorsCount() external view returns (uint256) {
        return depositors.length;
    }

    /// @notice 按下标查看某个存款用户地址
    function getDepositor(uint256 index) external view returns (address) {
        require(index < depositors.length, "Index out of range");
        return depositors[index];
    }

    /// @notice 返回交易记录总数
    function getTxHistoryLength() external view returns (uint256) {
        return txHistory.length;
    }

    /// @notice 查看某一条交易记录
    function getTx(
        uint256 index
    )
        external
        view
        returns (
            address user,
            uint256 amount,
            bool isDeposit,
            uint256 timestamp
        )
    {
        require(index < txHistory.length, "Index out of range");
        TxRecord storage r = txHistory[index];
        return (r.user, r.amount, r.isDeposit, r.timestamp);
    }

    /// @notice 查看某个用户所有交易记录的下标（再配合 getTx 使用）
    function getUserTxIds(
        address user
    ) external view returns (uint256[] memory) {
        return userTxIds[user];
    }
}
