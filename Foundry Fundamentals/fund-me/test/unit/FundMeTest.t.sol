// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import { FundMe } from "../../src/FundMe.sol";
import { Test, console } from "forge-std/Test.sol";
import { DeployFundMe } from "../../script/DeployFundMe.s.sol";


contract FundMeTest is Test {
    uint256 constant GAS_PRICE = 1;
    
    uint256 favNumber = 0;
    bool greatCourse = false;
    DeployFundMe deployFundMe;
    FundMe fundMe;
    address alice = makeAddr("alice");

    function setUp() external {
        favNumber = 1314;
        greatCourse = true;
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(alice, 100 ether);
    }

    modifier funded() {
        vm.prank(alice);
        fundMe.fund{value: 10 ether}();
        assert(address(fundMe).balance > 0);
        _;
    }

    function testDemo() view public {
        assertEq(favNumber, 1314);
        assertEq(greatCourse, true);
        console.log("This will get printed second!");
        console.log("Updraft is changing lives!");
        console.log("You can print multiple things, for example this is a uint256, followed by a bool:", favNumber, greatCourse);
    }

    function testMinimumDollarsFive() view public {
        assertEq(fundMe.MINIMAL_USD(), uint256(5));
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.owner(), msg.sender);
        // assertEq(fundMe.owner(), address(this));
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundDataStructure() public {
        vm.prank(alice);
        vm.deal(alice, 100 ether);
        fundMe.fund{value: 10 ether}();
        uint256 amountFunded = fundMe.addressToAmountFunded(alice);
        assertEq(amountFunded, 10 ether);
    }

    function testAddFunderToArrayOfFunders() public {
        vm.startPrank(alice);
        vm.deal(alice, 100 ether);
        fundMe.fund{value: 10 ether}();
        vm.stopPrank();

        address funder = fundMe.funders(0);
        assertEq(funder, alice);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawFromOwner() public {
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.owner().balance;

        vm.startPrank(fundMe.owner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.owner().balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromOwnerWithGas() public {
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.owner().balance;

        vm.txGasPrice(GAS_PRICE);
        uint256 gasStart = gasleft();

        vm.startPrank(fundMe.owner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log("Withdraw consumed: %d gas", gasUsed);

        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.owner().balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testPrintStorageData() public view {
        for (uint256 i = 0; i < 5; i++) {
            bytes32 value = vm.load(address(fundMe), bytes32(i));
            console.log("Value at location", i, ":");
            console.logBytes32(value);
        }
        console.log("PriceFeed address: ", address(fundMe.priceFeed()));
    }

}