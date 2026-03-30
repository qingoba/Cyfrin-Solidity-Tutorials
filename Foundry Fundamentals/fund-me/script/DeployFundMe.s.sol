// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import { Script } from "forge-std/Script.sol";
import { FundMe } from "../src/FundMe.sol";
import { HelperConfig } from "./HelperConig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // The next line runs before the vm.startBroadcast() is called
        // This will not be deployed because the `real` signed txs are happening
        // between the start and stop Broadcast lines.
        HelperConfig helperConfig = new HelperConfig();
        address priceFeed = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        FundMe fundMe = new FundMe(priceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}