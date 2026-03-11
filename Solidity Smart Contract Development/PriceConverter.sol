// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {

    /*
        Refer:
        function latestRoundData() external view
            returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
    */
    function getLatestPrice() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (, int price, , ,) = priceFeed.latestRoundData();
        return uint256(price * 1e10);      // convenient for later use (compute with uint msg.value) and convert to decimal 18
    }

    function getDecimals() internal view returns (uint8) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return priceFeed.decimals();
    }

    // calculate how many USDs the ethAmount ETH represents
    // ethAmount is 18 decimals, same as msg.value
    function getConversionRate(uint256 ethAmount) internal view returns (uint256) {
        uint256 ethPrice = getLatestPrice();    // also 18 decimals
        uint256 totalUSD = (ethPrice * ethAmount) / 1e18;   // make sure result is also 18 decimals
        return totalUSD;
    }
}