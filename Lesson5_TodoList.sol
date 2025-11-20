// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/// @title 每个地址都有自己的 Todo 列表
contract TodoList {
    /// @dev 任务结构体
    struct Task {
        string content;  // 任务内容
        bool completed;  // 是否完成
    }

    /// @dev 每个用户地址 => 该用户的任务数组
    mapping(address => Task[]) private tasksOf;

    /// @notice 创建一条新任务
    /// @param content 任务内容，比如 "学习 Lesson 5"
    function addTask(string calldata content) external {
        require(bytes(content).length > 0, "Content empty");

        Task memory task = Task({
            content: content,
            completed: false
        });

        tasksOf[msg.sender].push(task);
    }

    /// @notice 切换某条任务的完成状态（完成 <-> 未完成）
    /// @param index 任务下标（从 0 开始）
    function toggleTask(uint index) external {
        require(index < tasksOf[msg.sender].length, "Index out of range");

        Task storage task = tasksOf[msg.sender][index];
        task.completed = !task.completed;
    }

    /// @notice 查看自己某条任务的详情
    function getMyTask(uint index)
        external
        view
        returns (string memory content, bool completed)
    {
        require(index < tasksOf[msg.sender].length, "Index out of range");

        Task storage task = tasksOf[msg.sender][index];
        return (task.content, task.completed);
    }

    /// @notice 查看自己一共有多少条任务
    function getMyTaskCount() external view returns (uint) {
        return tasksOf[msg.sender].length;
    }
}
