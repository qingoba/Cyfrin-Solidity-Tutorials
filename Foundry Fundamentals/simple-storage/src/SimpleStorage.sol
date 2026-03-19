// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract SimpleStorage {
    uint256 myFavoriteNumber;

    struct Person {
        uint256 favoriteNumber;
        string name;
    }

    Person[] public listOfPeople;

    mapping(string => uint256) nameToFavoriteNumber;

    function store(uint256 number) public {
        myFavoriteNumber = number;
    }

    function retrieve() public view returns (uint256) {
        return myFavoriteNumber;
    }

    function addPerson(string memory name, uint256 number) public {
        listOfPeople.push(Person({favoriteNumber: number, name: name}));
        nameToFavoriteNumber[name] = number;
    }
}
