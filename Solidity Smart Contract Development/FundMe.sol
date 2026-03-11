// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import { PriceConverter } from "./PriceConverter.sol";
import { MathLibrary } from "./MathLibrary.sol";

using PriceConverter for uint256;
using MathLibrary for uint256;

contract FundMe {
    AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);

    address immutable owner;
    address[] funders;
    mapping (address => uint256) public addressToAmountFunded;
    mapping (address => uint256) public addressToCountFunded;
    uint256 constant MINIMAL_USD = 5;

    constructor() {
        owner = msg.sender;
    }

    function send() public payable {
        require(msg.value >= 1 ether, "At least send 1 Ether");
    }

    function tinyTip() public payable {
        require(msg.value <= 1e9, "At most send 1 Gwei");
    }

    /*
        Refer:
        function latestRoundData() external view
            returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
    */
    function getLatestPrice() public view returns (uint256) {
        (, int price, , ,) = priceFeed.latestRoundData();
        return uint256(price * 1e10);      // convenient for later use (compute with uint msg.value) and convert to decimal 18
    }

    function getDecimals() public view returns (uint8) {
        return priceFeed.decimals();
    }

    // calculate how many USDs the ethAmount ETH represents
    // ethAmount is 18 decimals, same as msg.value
    function getConversionRate(uint256 ethAmount) public view returns (uint256) {
        uint256 ethPrice = getLatestPrice();    // also 18 decimals
        uint256 totalUSD = (ethPrice * ethAmount) / 1e18;   // make sure result is also 18 decimals
        return totalUSD;
    }

    function send_check_usd() public payable {
        require(msg.value.getConversionRate() >= MINIMAL_USD, "At least send 5 USD");
        addressToAmountFunded[msg.sender] += msg.value;
        addressToCountFunded[msg.sender] += 1;
        funders.push(msg.sender);
    }

    // we assume the usdAmount argument is zero decimal, so we multiply it by 1e18 at first
    function convertUSDtoETH(uint256 usdAmount) public view returns (uint256) {
        usdAmount = usdAmount * 1e18;
        uint256 ethPrice = getLatestPrice();
        uint256 ethAmount = (usdAmount * 1e18) / ethPrice;
        return ethAmount;
    }

    function contributionCount(address user) public view returns (uint256) {
        return addressToCountFunded[user];
    }

    function calculateSum(uint256 num1, uint256 num2) public pure returns (uint256) {
        return MathLibrary.sum(num1, num2);
    }

    function clear() public {
        for (uint256 i = 0; i < funders.length; i++) {
            address user = funders[i];
            addressToAmountFunded[user] = 0;
            addressToCountFunded[user] = 0;
        }
        delete funders;
    }

    function callAmountTo(address user) public {
        (bool success, ) = payable(user).call{ value: address(this).balance }("");
        require(success, "callAmountTo failure");
    }

    function withdrawOnlyFirstAccountRemix() public {
        require(msg.sender == owner, "only the contract owner can withdraw");
        clear();
    }

    modifier onlyAfter(uint256 limitTimestamp) {
        require(block.timestamp >= limitTimestamp, "only after a sepcific ts");
        _;
    }

    error NotOwner();

    function withdrawCustomError() public {
        if (msg.sender != owner) {
            revert NotOwner();
        }
        clear();
    }

    receive() external payable {
        send_check_usd();
    }

    fallback() external payable {
        send_check_usd();
    }
}