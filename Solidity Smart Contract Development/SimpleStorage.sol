// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;


struct Person {
    uint256 favoriteNumber;
    string name;
}

struct Animal {
    string name;
    uint32 weight;
}

contract SimpleStorage {
    uint256 public favoriteNumber = 88;
    bool hasFavoriteNumber = false;
    string favoriteNumberInText = "eighty-eight";
    int256 favoriteInt = -88;
    address myAddress = 0x4a27D4D98Cf6194E2B588266699fdE51d0e7eDCe;
    bytes32 myPet = "cat";

    Person[] public list_of_people;

    mapping (address => uint256) addressToBalance;

  
    // UnimplementedFeatureError: Copying of type struct Animal memory[3] memory to storage not yet supported.
    // Animal[] public list_of_animals = [Animal("Dog", 10), Animal("Cat", 5), Animal("Pig", 15)];  // can't do this in Solidity
    Animal[] public list_of_animals;

    constructor() {
        list_of_animals.push(Animal("Bird", 1));
        list_of_animals.push(Animal("Cat", 3));
        list_of_animals.push(Animal("Dog", 10));
    }

    function store(uint256 number) public virtual {
        favoriteNumber = number;
    }

    function retrive() public view returns (uint256) {
        return favoriteNumber;
    }

    function retrive_private() private view returns (uint256) {
        return favoriteNumber;
    }

    function retrive_only_from_outside() external pure returns (uint256) {
        return 88;
    }

    function retrive_internal() internal view returns (uint256) {
        return favoriteNumber;
    }

    function add_people(string calldata name, uint256 number) public {
        list_of_people.push(Person(number, name));
    }

    function add_animal_indefinite(Animal[] memory animals) public {
        for (uint256 i = 0; i < animals.length; i++) {
            list_of_animals.push(animals[i]);
        }
    }

    function update_balance(address addr, uint256 balance) public {
        addressToBalance[addr] = balance;
    }

    function retrive_balance(address addr) public view returns (uint256) {
        return addressToBalance[addr];
    }
}