// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { SimpleStorage } from "./SimpleStorage.sol";

contract AddFiveStorage is SimpleStorage {
    function store(uint256 number) public override {
        favoriteNumber = number + 5;
    }
}
