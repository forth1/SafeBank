// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title 一个最简单的可复用 Ownable 合约
contract OwnableSimple {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "zero");
        owner = newOwner;
    }
}

/// @title 使用继承的银行合约
/// SafeBankV2 自动拥有 OwnableSimple 里的 owner / onlyOwner / transferOwnership
contract SafeBankV2 is OwnableSimple {
    mapping(address => uint256) public balances;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    // 存款，所有人都可以存
    function deposit() external payable {
        require(msg.value > 0, "amount = 0");

        balances[msg.sender] += msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    // 取款，只能本人取自己的钱
    function withdraw(uint256 amount) external {
        require(amount > 0, "amount = 0");
        require(balances[msg.sender] >= amount, "balance not enough");

        balances[msg.sender] -= amount;

        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "ETH transfer failed");

        emit Withdraw(msg.sender, amount);
    }

    // 只有 owner 可以把合约里的余额提走（比如项目关闭时清算）
    function emergencyWithdrawAll() external onlyOwner {
        uint256 bal = address(this).balance;
        require(bal > 0, "no ETH");

        (bool ok, ) = owner.call{value: bal}("");
        require(ok, "transfer failed");
    }
}
