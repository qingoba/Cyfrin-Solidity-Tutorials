// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { SimpleStorage } from "./SimpleStorage.sol";

contract StorageFactory {
    SimpleStorage[] public listOfSimpleStorage ;

    function createSimpleStorageContract() public {
        SimpleStorage inst = new SimpleStorage();
        listOfSimpleStorage.push(inst);
    }

    function sfStore(uint256 index, uint256 number) public {
        listOfSimpleStorage[index].store(number);
    }

    function sfGet(uint256 index) public view returns (uint256) {
        return listOfSimpleStorage[index].retrive();
    }
}