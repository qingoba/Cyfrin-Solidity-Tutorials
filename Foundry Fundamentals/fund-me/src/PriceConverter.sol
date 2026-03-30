// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {

    function getLatestPrice(uint256 /* ethAmount */, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        (, int price, , ,) = priceFeed.latestRoundData();
        return uint256(price * 1e10);
    }

    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        uint256 ethPrice = getLatestPrice(ethAmount, priceFeed);
        uint256 totalUSD = (ethPrice * ethAmount) / 1e18;
        return totalUSD;
    }
}
