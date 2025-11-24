// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract EventDemo {

    event MessageChanged(address indexed user, string oldMsg, string newMsg);

    string public message;

    function setMessage(string calldata _msg) external {
        string memory old = message;
        message = _msg;

        emit MessageChanged(msg.sender, old, _msg);
    }
}
