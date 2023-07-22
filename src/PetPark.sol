//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract PetPark is Ownable {
    enum AnimalType {
        None,
        Fish,
        Cat,
        Dog,
        Rabbit,
        Parrot
    }

    enum Gender {
        Male,
        Female
    }

    struct Loan {
        uint256 age;
        AnimalType animalType;
        Gender gender;
    }

    event Added(AnimalType animalType, uint256 count);
    event Borrowed(AnimalType animalType);
    event Returned(AnimalType animalType);

    mapping(AnimalType animalType => uint256 count) public animalCounts;
    mapping(address borrower => Loan loan) public loans;

    constructor() Ownable() {}

    function add(AnimalType animalType, uint256 count) external onlyOwner {
        require(animalType != AnimalType.None, "Invalid animal");
        animalCounts[animalType] += count;
        emit Added(animalType, count);
    }

    function borrow(uint256 age, Gender gender, AnimalType animalType) external {
        require(age > 0, "Age must be greater than 0");
        require(animalType != AnimalType.None, "Invalid animal type");
        require(animalCounts[animalType] > 0, "Selected animal not available");
        Loan storage loan = loans[msg.sender];
        if (loan.animalType != AnimalType.None) {
          require(loan.age == age, "Invalid Age");
          require(loan.gender == gender, "Invalid Gender");
          revert("Already adopted a pet");
        }
        if (gender == Gender.Male) {
            require((animalType == AnimalType.Dog || animalType == AnimalType.Fish), "Invalid animal for men");
        } else {
            require(age < 40 && animalType != AnimalType.Cat, "Invalid animal for women under 40");
        }
        loans[msg.sender] = Loan(age, animalType, gender);
        animalCounts[loan.animalType] -= 1;
        emit Borrowed(animalType);
    }

    function giveBackAnimal() external {
        Loan storage loan = loans[msg.sender];
        require(loan.animalType != AnimalType.None, "No borrowed pets");
        animalCounts[loan.animalType] += 1;
        loan.animalType = AnimalType.None;
    }
}
