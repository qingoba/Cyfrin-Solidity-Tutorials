// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PriceContract {
    AggregatorV3Interface priceFeed = AggregatorV3Interface(0x5fb1616F78dA7aFC9FF79e0371741a747D2a7F22);

    function getLatestBTCPriceInETH() public view returns (uint256) {
        (, int price, , ,) = priceFeed.latestRoundData();
        return uint256(price);
    }
}