// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ControlFlowDemo {

    uint256 public totalDeposits;

    function deposit() external payable {
        require(msg.value > 0,unicode"金額不能為 0");

        totalDeposits += msg.value;

        if (totalDeposits > 100 ether) {
            revert(unicode"存款超過上限 100 ETH");
        }
    }

    function strictCheck(uint x) external pure returns(uint) {
        assert(x != 999);  // unicode"绝不允许的情况"
        return x * 2;
    }
}
