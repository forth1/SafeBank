// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LoopTest {
    function sumArray(uint[] memory arr) public pure returns (uint) {
        uint total = 0;
        for (uint i = 0; i < arr.length; i++) {
            total += arr[i];
        }
        return total;
    }
}
