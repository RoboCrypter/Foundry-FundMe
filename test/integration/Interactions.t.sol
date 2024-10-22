// SPDX-License-Identifier: MIT

pragma solidity ^0.8.27;

import {Test, console2} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {FundMe_Fund, FundMe_Withdraw} from "../../script/Interactions.s.sol";
import {FundMeScript} from "../../script/FundMe.s.sol";

contract InteractionsTest is Test {
    FundMe private fundMe;

    function setUp() external {
        if (block.chainid == 11155111) {
            fundMe = FundMe(0x5d5baA64B2434946E33041Bfb918AFA248b60ad3);
        } else {
            FundMeScript fundMeScript = new FundMeScript();

            fundMe = fundMeScript.run();
        }
    }

    function testIntegrationUserCanFund() external {
        uint256 fundMeContractBeforeBalance = fundMe.getContractBalance();

        FundMe_Fund fundMe_fund_contract = new FundMe_Fund();

        address user = fundMe_fund_contract.USER();

        vm.deal(user, 1 ether);

        uint256 userBeforeBalance = user.balance;

        fundMe_fund_contract.fundMe_fund(address(fundMe));

        address funder = fundMe.getFunder(0);

        uint256 fundersLength = fundMe.getNumberOfFunders();

        uint256 fundedAmount = fundMe.getFunderToAmount(user);

        uint256 fundMeContractAfterBalance = fundMe.getContractBalance();

        uint256 userAfterBalance = user.balance;

        assertEq(funder, user);

        assertEq(fundersLength, 1);

        assertEq(fundedAmount, fundMeContractAfterBalance);

        assertEq(fundMeContractBeforeBalance, 0);

        assertEq(userAfterBalance, userBeforeBalance - fundMeContractAfterBalance);
    }

    function testIntegrationOwnerCanWithdraw() external {
        // Funding

        FundMe_Fund fundMe_fund_contract = new FundMe_Fund();

        address user = fundMe_fund_contract.USER();

        uint256 fundAmount = fundMe_fund_contract.FUND_AMOUNT();

        vm.deal(user, 1 ether);

        uint256 userBeforeBalance = user.balance;

        fundMe_fund_contract.fundMe_fund(address(fundMe));

        uint256 userAfterBalance = user.balance;

        assertEq(userAfterBalance, userBeforeBalance - fundAmount);

        // Withdrawing

        uint256 fundMeContractBeforeBalance = fundMe.getContractBalance();

        FundMe_Withdraw fundMe_withdraw_contract = new FundMe_Withdraw();

        address owner = fundMe.getOwner();

        uint256 ownerBeforeBalance = owner.balance;

        fundMe_withdraw_contract.fundMe_withdraw(address(fundMe));

        uint256 fundersLength = fundMe.getNumberOfFunders();

        uint256 fundMeContractAfterBalance = fundMe.getContractBalance();

        uint256 ownerAfterBalance = owner.balance;

        assertEq(fundersLength, 0);

        assertEq(ownerAfterBalance, ownerBeforeBalance + fundMeContractBeforeBalance);

        assertEq(fundMeContractAfterBalance, 0);
    }
}
