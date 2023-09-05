// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;


import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";


/**
*@title FundMe contract
*@author M.Siddique
*@notice This contract is able to receive funds and withdraw funds
*@dev This contract implements chainlink price feeds
*/


contract FundMe is ReentrancyGuard {

    // Errors

    error FundMe__Less_than_minimum_funding_amount();
    error FundMe__Not_owner();
    error FundMe__Transfer_failed();


    // Type Declarations

    using PriceConverter for uint256;


    // State Variables

    address private immutable i_owner;

    AggregatorV3Interface private s_priceFeedAddress;

    uint256 private constant MINIMUM_AMOUNT_IN_USD = 50 * 10 ** 18;

    address[] private s_funders;

    mapping(address funder => uint256 amountFunded) private s_funderToAmount;


    // Events

    event Fund(address indexed funder, uint256 indexed fundedAmount);

    event Withdraw(address indexed owner, uint256 indexed withdrawnAmount);


    // Modifiers

    modifier onlyOwner() {

        if(msg.sender != i_owner) revert FundMe__Not_owner();

        _;
    }


    // Constructor

    constructor(address _priceFeedAddress) {

        i_owner = msg.sender;

        s_priceFeedAddress = AggregatorV3Interface(_priceFeedAddress);
    }


    // Public & External Functions

    function fund() external payable {

        if(msg.value.ethToUsdConversion(s_priceFeedAddress) < MINIMUM_AMOUNT_IN_USD) revert FundMe__Less_than_minimum_funding_amount();

        s_funderToAmount[msg.sender] += msg.value;

        s_funders.push(msg.sender);

        emit Fund(msg.sender, msg.value);
    }


    function withdraw() external onlyOwner nonReentrant {

        uint256 fundersLength = s_funders.length;

        for(uint256 i = 0; i < fundersLength; i++) {

            s_funderToAmount[s_funders[i]] = 0;
        }

        s_funders = new address[](0);

        uint256 contractBalance = address(this).balance;

        (bool success, ) = i_owner.call{ value: address(this).balance }("");

        if(!success) revert FundMe__Transfer_failed();

        emit Withdraw(msg.sender, contractBalance);
    }


    // View & Pure Functions

    function getMinimumFundingAmount() external pure returns(uint256) {

        return MINIMUM_AMOUNT_IN_USD;
    }


    function getFunder(uint256 index) external view returns(address) {

        return s_funders[index];
    }


    function getNumberOfFunders() external view returns(uint256) {

        return s_funders.length;
    }


    function getFunderToAmount(address funder) external view returns(uint256) {

        return s_funderToAmount[funder];
    }


    function getPriceFeedAddress() external view returns(AggregatorV3Interface) {

        return s_priceFeedAddress;
    }


    function getContractBalance() external view returns(uint256) {

        return address(this).balance;
    }


    function getOwner() external view returns(address) {

        return i_owner;
    }
}