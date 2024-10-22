// SPDX-License-Identifier: MIT

pragma solidity ^0.8.27;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library EthToUsdConvertor {
    function getEthPrice(address _priceFeedAddress) internal view returns (uint256) {
        // AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).latestRoundData();
        
        (, int256 price,,,) = AggregatorV3Interface(_priceFeedAddress).latestRoundData();

        // "price" will return in 8 decimals format: 2000.00000000 | assumed ETH price = 2000 USD

        // since ETH has 18 decimals

        return uint256(price * 1e10);  // so, we have to multiply "price" with 10 decimals: '10000000000' || '1 ** 10' || '1e10'

        // 2000.00000000 * 10000000000 || 2 ** 8 * 1 ** 10 || 2e8 * 1e10
    }

    function ethToUsdConversion(uint256 _ethAmount, address _priceFeedAddress)
        internal
        view
        returns (uint256)
    {
        uint256 ethPrice = getEthPrice(_priceFeedAddress);

        uint256 ethToUsd = (_ethAmount * ethPrice) / 1e18;

        // if we put "_ethAmount" = 2 ETH || 2000000000000000000 | assumed ETH price = 2000 USD

        // 2000000000000000000 * 2000,000000000000000000 = 4000,000000000000000000,000000000000000000

        // 1e18 || 1 ** 18 || 1000000000000000000 to get rid of all the extra decimals

        // 2000000000000000000 * 2000,000000000000000000 / 1000000000000000000

        // = 4000,000000000000000000 || 4000e18 USD in WEI

        return ethToUsd;
    }
}
