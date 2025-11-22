// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Lesson11_ArrayDemo {

    /// ---------------------------------------------------------
    /// 1. 固定数组（长度固定）
    /// ---------------------------------------------------------
    uint256[3] public fixedArr = [1, 2, 3];

    /// 获取某一个位置
    function getFixed(uint index) external view returns(uint256) {
        require(index < fixedArr.length, "out of range");
        return fixedArr[index];
    }

    /// 修改（只能修改，不能增加）
    function setFixed(uint index, uint256 value) external {
        require(index < fixedArr.length, "out of range");
        fixedArr[index] = value;
    }


    /// ---------------------------------------------------------
    /// 2. 动态数组（长度可变）
    /// ---------------------------------------------------------
    uint256[] public dynamicArr;

    /// push 添加
    function pushDynamic(uint256 value) external {
        dynamicArr.push(value);
    }

    /// pop 删除最后一个
    function popDynamic() external {
        require(dynamicArr.length > 0, "empty");
        dynamicArr.pop();
    }

    /// 获取动态数组全长
    function getDynamicLength() external view returns(uint256) {
        return dynamicArr.length;
    }

    /// 获取某个元素
    function getDynamic(uint index) external view returns(uint256) {
        return dynamicArr[index];
    }


    /// ---------------------------------------------------------
    /// 3. 二维数组（matrix）
    /// ---------------------------------------------------------
    uint256[][] public matrix;

    /// push 一个子数组，如 [1,2,3]
    function pushRow(uint256[] calldata row) external {
        matrix.push(row);
    }

    /// 获取某一行
    function getRow(uint row) external view returns(uint256[] memory) {
        return matrix[row];
    }

    /// 获取某一个位置的数字
    function getMatrixValue(uint r, uint c) external view returns(uint256) {
        return matrix[r][c];
    }
}
