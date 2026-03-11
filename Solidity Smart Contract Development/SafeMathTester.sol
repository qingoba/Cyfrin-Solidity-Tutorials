// SPDX-License-Identifier: MIT
pragma solidity 0.6.0;

import "@openzeppelin/contracts@3.4.2/math/SafeMath.sol";

contract SafeMathTester {
    uint256 public bigNumber = 2**256 - 1;

    function add() public {
        bigNumber = SafeMath.add(bigNumber, 1);
    }
}