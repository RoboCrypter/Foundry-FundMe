// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;


import {FundMe} from "../../src/FundMe.sol";
import {Test, console} from "forge-std/Test.sol";
import {FundMeScript} from "../../script/FundMe.s.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


contract FundMeTest is Test {
    
    FundMe private fundMe;

    address private activePriceFeedAddress;

    uint256 private FUND_AMOUNT = 0.1 ether;

    address private USER = makeAddr("USER");


    event Fund(address indexed funder, uint256 indexed fundedAmount);

    event Withdraw(address indexed owner, uint256 indexed withdrawnAmount);


    modifier funded() {

        vm.prank(USER);

        fundMe.fund{ value: FUND_AMOUNT }();

        _;
    }


    function setUp() external {

        FundMeScript fundMeScript = new FundMeScript();

        fundMe = fundMeScript.run();

        activePriceFeedAddress = address(fundMe.getPriceFeedAddress());

        vm.deal(USER, 10 ether);
    }


    function testMinimumAmountInUsd() external {

        uint256 minimumFundingAmount = fundMe.getMinimumFundingAmount();

        assertEq(minimumFundingAmount, 50e18);
    }


    function testOwnerIsMsgSender() external {

        address owner = fundMe.getOwner();

        assertEq(owner, msg.sender);
    }


    function testPriceFeedAddress() external {

        AggregatorV3Interface priceFeedAddress = fundMe.getPriceFeedAddress();

        assertEq(address(priceFeedAddress), activePriceFeedAddress);
    }


    function testContractBalance() external {

        uint256 contractBalance = fundMe.getContractBalance();

        assertEq(contractBalance, 0);
    }


    function testFundFunction() external {

        vm.prank(USER);

        fundMe.fund{ value: FUND_AMOUNT }();

        address funder = fundMe.getFunder(0);

        uint256 amountFunded = fundMe.getFunderToAmount(funder);

        uint256 fundersLength = fundMe.getNumberOfFunders();

        uint256 contractBalance = fundMe.getContractBalance();

        assertEq(funder, USER);

        assertEq(amountFunded, FUND_AMOUNT);

        assertEq(fundersLength, 1);

        assertEq(contractBalance, FUND_AMOUNT);
    }


    function testFundFunctionByFundingLessThanMinimumAmount() external {

        vm.expectRevert();

        fundMe.fund{ value: 0.028 ether }();
    }


    function testFundEvent() external {

        vm.expectEmit(true, true, false, true);

        emit Fund(USER, FUND_AMOUNT);

        vm.prank(USER);

        fundMe.fund{ value: FUND_AMOUNT }();
    }


    function testWithdrawFunction() external funded {

        uint256 fundMeContractBeforeBalance = fundMe.getContractBalance();

        uint256 ownerBeforeBalance = fundMe.getOwner().balance;

        vm.prank(fundMe.getOwner());

        fundMe.withdraw();

        uint256 fundMeContractAfterBalance = fundMe.getContractBalance();

        uint256 ownerAfterBalance = fundMe.getOwner().balance;

        assertEq(fundMeContractBeforeBalance, FUND_AMOUNT);

        assertEq(fundMeContractAfterBalance, 0);

        assertEq(ownerAfterBalance, ownerBeforeBalance + fundMeContractBeforeBalance);
    }


    function testWithdrawFunctionByWithdrawingAsNonOwner() external {

        vm.expectRevert();

        vm.prank(USER);

        fundMe.withdraw();
    }


    function testWithdrawEvent() external funded {

        vm.expectEmit(true, true, false, true);

        emit Withdraw(msg.sender, FUND_AMOUNT);

        vm.prank(fundMe.getOwner());

        fundMe.withdraw();
    }


    function testFundAndWithdrawFunctionByFundingThroughMultipleFundersAndThenWithdrawing() external {

        // Funding

        uint160 startingNumber = 1;

        uint160 totalNumberOfFunders = 10;

        for(uint160 i = startingNumber; i <= totalNumberOfFunders; i++) {

            hoax(address(i), 1 ether);

            fundMe.fund{ value: FUND_AMOUNT }();
        }

        assertEq(fundMe.getContractBalance(), FUND_AMOUNT * totalNumberOfFunders);

        assertEq(fundMe.getNumberOfFunders(), totalNumberOfFunders);

        // Withdrawing

        uint256 fundMeContractBeforeBalance = fundMe.getContractBalance();

        uint256 ownerBeforeBalance = fundMe.getOwner().balance;

        vm.startPrank(fundMe.getOwner());

        fundMe.withdraw();

        vm.stopPrank();

        uint256 fundMeContractAfterBalance = fundMe.getContractBalance();

        uint256 ownerAfterBalance = fundMe.getOwner().balance;

        assertEq(fundMeContractBeforeBalance, FUND_AMOUNT * totalNumberOfFunders);

        assertEq(fundMeContractAfterBalance, 0);

        assertEq(ownerAfterBalance, ownerBeforeBalance + fundMeContractBeforeBalance);

        assertEq(fundMe.getNumberOfFunders(), 0);
    }
}