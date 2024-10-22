// SPDX-License-Identifier: MIT

pragma solidity ^0.8.27;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "@chainlink/contracts/src/v0.8/tests/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint8 private constant DECIMALS = 8;  // We are giving "8" because "ETH" has "8 decimals"

    int256 private constant INITIAL_ANSWER = 2000e8;  // Means "ETH" price is "2000 USD" currently at this time.

    struct NetworkConfig {
        address priceFeedAddress;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaNetworkConfig();
        } else {
            activeNetworkConfig = getAnvilNetworkConfig();
        }
    }

    function getSepoliaNetworkConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaEthConfig =
            NetworkConfig({priceFeedAddress: 0x694AA1769357215DE4FAC081bf1f309aDC325306});

        return sepoliaEthConfig;
    }

    function getAnvilNetworkConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeedAddress != address(0)) {
            // If we already setted up a mock priceFeedAddress then just return that priceFeedAddress.
            return activeNetworkConfig; // and don't deploy again a new mockV3Aggregator for priceFeedAddress.
        }

        vm.startBroadcast();

        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);

        vm.stopBroadcast();

        NetworkConfig memory anvilEthConfig = NetworkConfig({priceFeedAddress: address(mockV3Aggregator)});

        return anvilEthConfig;
    }
}
