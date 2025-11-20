// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/// @title Lesson5 数组 & 映射 Demo
contract ArrayMappingDemo {
    // ------------ 一、动态数组 --------------

    // 一个简单的 uint 动态数组
    uint[] public numbers;

    /// @notice 往数组里追加一个数字
    function addNumber(uint value) external {
        numbers.push(value);
    }

    /// @notice 改某个位置的数字
    function updateNumber(uint index, uint newValue) external {
        require(index < numbers.length, "Index out of range");
        numbers[index] = newValue;
    }

    /// @notice 删除最后一个数字
    function removeLast() external {
        require(numbers.length > 0, "Array is empty");
        numbers.pop();
    }

    /// @notice 数组长度
    function getLength() external view returns (uint) {
        return numbers.length;
    }

    // ------------ 二、简单 mapping ------------

    // 每个地址对应一个余额（只是练习，不是真實代币）
    mapping(address => uint) public mockBalances;

    /// @notice 给某个地址“充钱”（owner 调试用）
    function setBalance(address user, uint amount) external {
        mockBalances[user] = amount;
    }

    /// @notice 查询自己的余额
    function getMyBalance() external view returns (uint) {
        return mockBalances[msg.sender];
    }

    // --------- 三、mapping + 数组 组合 ---------

    // 每个地址 => 它拥有的“标签”数组
    mapping(address => string[]) private tagsOf;

    /// @notice 给自己添加一个标签
    function addMyTag(string calldata tag) external {
        tagsOf[msg.sender].push(tag);
    }

    /// @notice 查看自己第 index 个标签
    function getMyTag(uint index) external view returns (string memory) {
        require(index < tagsOf[msg.sender].length, "Tag index out of range");
        return tagsOf[msg.sender][index];
    }

    /// @notice 查看自己一共有多少个标签
    function getMyTagCount() external view returns (uint) {
        return tagsOf[msg.sender].length;
    }
}
