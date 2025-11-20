// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// @title A safe ETH bank with whitelist + anti-reentrancy
/// @author forth

contract SafeBank {

    // --- 防重入锁 ---
    bool private locked;

    modifier nonReentrant() {
        require(!locked, "Reentrancy blocked");
        locked = true;
        _;
        locked = false;
    }

    // --- Owner（管理员） ---
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // --- 白名单 ---
    mapping(address => bool) public whitelist;

    event AddedToWhitelist(address account);
    event RemovedFromWhitelist(address account);
    event Deposit(address user, uint amount);
    event Withdraw(address user, uint amount);

    // 添加白名单
    function addWhitelist(address account) external onlyOwner {
        whitelist[account] = true;
        emit AddedToWhitelist(account);
    }

    // 移除白名单
    function removeWhitelist(address account) external onlyOwner {
        whitelist[account] = false;
        emit RemovedFromWhitelist(account);
    }

    modifier onlyWhitelist() {
        require(whitelist[msg.sender], "Not in whitelist");
        _;
    }

    // --- 用户余额 ---
    mapping(address => uint256) public balances;

    // 存钱（只有白名单可以）
    function deposit() external payable onlyWhitelist {
        require(msg.value > 0, "Deposit must > 0");
        balances[msg.sender] += msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    // 取钱（只有白名单可以）
    function withdraw(uint amount) external nonReentrant onlyWhitelist {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;

        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "Withdraw failed");

        emit Withdraw(msg.sender, amount);
    }

    // 查询个人余额
    function getMyBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

    // 查询银行总余额
    function getBankBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
