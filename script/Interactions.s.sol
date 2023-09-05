// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;


import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";


contract FundMe_Fund is Script {

    address public USER = makeAddr("USER");

    uint256 public FUND_AMOUNT = 0.1 ether;


    function fundMe_fund(address deployedFundMeContract) public {

        FundMe fundMe = FundMe(payable(deployedFundMeContract));

        vm.startBroadcast(USER);

        fundMe.fund{ value: FUND_AMOUNT }();

        vm.stopBroadcast();

        console.log("Funded!");
    }
}



contract FundMe_Withdraw is Script {

    function fundMe_withdraw(address deployedFundMeContract) public {

        FundMe fundMe = FundMe(payable(deployedFundMeContract));

        address owner = fundMe.getOwner();

        vm.startBroadcast(owner);

        fundMe.withdraw();

        vm.stopBroadcast();

        console.log("Withdrawn!");
    }
}