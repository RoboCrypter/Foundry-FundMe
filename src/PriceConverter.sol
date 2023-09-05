// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;


import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


library PriceConverter {

    function getEthPrice(AggregatorV3Interface _priceFeedAddress) internal view returns(uint256) {

        // AggregatorV3Interface _priceFeedAddress = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);

        (, int price, , , ) = _priceFeedAddress.latestRoundData();

        return uint256(price * 1e10);
    }


    function ethToUsdConversion(uint256 _ethAmount, AggregatorV3Interface _priceFeedAddress) internal view returns(uint256) {

        uint256 ethPrice = getEthPrice(_priceFeedAddress);

        uint256 ethToUsd = _ethAmount * ethPrice / 1e18;

        return ethToUsd;
    }
}