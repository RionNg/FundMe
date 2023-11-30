// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract SafeMathTesterV8 {

    uint256 public bigNumber = 255; // checked

    function add() public {
        unchecked {bigNumber += 1; }
        // unchecked {bigNumber = bigNumber +1; }
    }
}