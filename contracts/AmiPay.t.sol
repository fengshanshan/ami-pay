// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {AmiPay} from "./AmiPay.sol";
import {TestToken} from "./TestToken.sol";

contract AmiPayTest is Test {
    AmiPay ap;
    TestToken tt;

    address sponsor;
    address beneficiary;
    address recipient;

    uint256 constant INITIAL_BALANCE = 100000 * 1e6; // 100k USDC with 6 decimals
    uint256 constant DEPOSIT_AMOUNT = 1000 * 1e6; // 1k USDC
    uint256 constant SPEND_AMOUNT = 500 * 1e6; // 500 USDC

    function setUp() public {
        tt = new TestToken();
        ap = new AmiPay(address(tt));

        sponsor = address(0x1);
        beneficiary = address(0x2);
        recipient = address(0x3);

        // Give sponsor some tokens
        tt.mint(sponsor, INITIAL_BALANCE);
    }

    // ============ Constructor Tests ============

    function test_Constructor_ValidToken() public {
        TestToken newToken = new TestToken();
        AmiPay newAmiPay = new AmiPay(address(newToken));
        assertEq(address(newAmiPay.supportToken()), address(newToken));
    }

    function test_Constructor_InvalidToken() public {
        vm.expectRevert(AmiPay.InvalidAddress.selector);
        new AmiPay(address(0));
    }

    // ============ depositAllowance Tests ============

    function test_DepositAllowance_Success() public {
        vm.prank(sponsor);
        tt.approve(address(ap), DEPOSIT_AMOUNT);

        vm.prank(sponsor);
        ap.depositAllowance(beneficiary, DEPOSIT_AMOUNT);

        assertEq(ap.allowances(beneficiary, sponsor), DEPOSIT_AMOUNT);
        assertEq(tt.balanceOf(address(ap)), DEPOSIT_AMOUNT);
        assertEq(tt.balanceOf(sponsor), INITIAL_BALANCE - DEPOSIT_AMOUNT);
    }

    function test_DepositAllowance_InvalidBeneficiary() public {
        vm.prank(sponsor);
        tt.approve(address(ap), DEPOSIT_AMOUNT);

        vm.prank(sponsor);
        vm.expectRevert(AmiPay.InvalidAddress.selector);
        ap.depositAllowance(address(0), DEPOSIT_AMOUNT);
    }

    function test_DepositAllowance_InvalidAmount() public {
        vm.prank(sponsor);
        tt.approve(address(ap), DEPOSIT_AMOUNT);

        vm.prank(sponsor);
        vm.expectRevert(AmiPay.InvalidAmount.selector);
        ap.depositAllowance(beneficiary, 0);
    }

    function test_DepositAllowance_InsufficientBalance() public {
        uint256 largeAmount = INITIAL_BALANCE + 1;
        vm.prank(sponsor);
        tt.approve(address(ap), largeAmount);

        vm.prank(sponsor);
        vm.expectRevert();
        ap.depositAllowance(beneficiary, largeAmount);
    }

    function test_DepositAllowance_MultipleDeposits() public {
        vm.prank(sponsor);
        tt.approve(address(ap), DEPOSIT_AMOUNT * 2);

        vm.prank(sponsor);
        ap.depositAllowance(beneficiary, DEPOSIT_AMOUNT);

        vm.prank(sponsor);
        ap.depositAllowance(beneficiary, DEPOSIT_AMOUNT);

        assertEq(ap.allowances(beneficiary, sponsor), DEPOSIT_AMOUNT * 2);
    }

    function test_DepositAllowance_EventEmitted() public {
        vm.prank(sponsor);
        tt.approve(address(ap), DEPOSIT_AMOUNT);

        vm.expectEmit(true, true, false, false);
        emit AmiPay.AllowanceDeposited(sponsor, beneficiary, DEPOSIT_AMOUNT);

        vm.prank(sponsor);
        ap.depositAllowance(beneficiary, DEPOSIT_AMOUNT);
    }

    function test_DepositAllowance_MultipleBeneficiaries() public {
        address beneficiary2 = address(0x4);

        vm.prank(sponsor);
        tt.approve(address(ap), DEPOSIT_AMOUNT * 2);

        vm.prank(sponsor);
        ap.depositAllowance(beneficiary, DEPOSIT_AMOUNT);

        vm.prank(sponsor);
        ap.depositAllowance(beneficiary2, DEPOSIT_AMOUNT);

        assertEq(ap.allowances(beneficiary, sponsor), DEPOSIT_AMOUNT);
        assertEq(ap.allowances(beneficiary2, sponsor), DEPOSIT_AMOUNT);
    }

    // ============ spendFrom Tests ============

    function test_SpendFrom_Success() public {
        // Setup: deposit allowance first
        vm.prank(sponsor);
        tt.approve(address(ap), DEPOSIT_AMOUNT);
        vm.prank(sponsor);
        ap.depositAllowance(beneficiary, DEPOSIT_AMOUNT);

        uint256 recipientBalanceBefore = tt.balanceOf(recipient);

        // Spend from allowance
        vm.prank(beneficiary);
        ap.spendFrom(sponsor, recipient, SPEND_AMOUNT);

        assertEq(
            ap.allowances(beneficiary, sponsor),
            DEPOSIT_AMOUNT - SPEND_AMOUNT
        );
        assertEq(
            tt.balanceOf(recipient),
            recipientBalanceBefore + SPEND_AMOUNT
        );
        assertEq(tt.balanceOf(address(ap)), DEPOSIT_AMOUNT - SPEND_AMOUNT);
    }

    function test_SpendFrom_InvalidRecipient() public {
        // Setup: deposit allowance first
        vm.prank(sponsor);
        tt.approve(address(ap), DEPOSIT_AMOUNT);
        vm.prank(sponsor);
        ap.depositAllowance(beneficiary, DEPOSIT_AMOUNT);

        vm.prank(beneficiary);
        vm.expectRevert(AmiPay.InvalidAddress.selector);
        ap.spendFrom(sponsor, address(0), SPEND_AMOUNT);
    }

    function test_SpendFrom_InvalidAmount() public {
        // Setup: deposit allowance first
        vm.prank(sponsor);
        tt.approve(address(ap), DEPOSIT_AMOUNT);
        vm.prank(sponsor);
        ap.depositAllowance(beneficiary, DEPOSIT_AMOUNT);

        vm.prank(beneficiary);
        vm.expectRevert(AmiPay.InvalidAmount.selector);
        ap.spendFrom(sponsor, recipient, 0);
    }

    function test_SpendFrom_InsufficientAllowance() public {
        // Setup: deposit allowance first
        vm.prank(sponsor);
        tt.approve(address(ap), DEPOSIT_AMOUNT);
        vm.prank(sponsor);
        ap.depositAllowance(beneficiary, DEPOSIT_AMOUNT);

        uint256 tooMuch = DEPOSIT_AMOUNT + 1;
        vm.prank(beneficiary);
        vm.expectRevert(AmiPay.InsufficientAllowance.selector);
        ap.spendFrom(sponsor, recipient, tooMuch);
    }

    function test_SpendFrom_NoAllowance() public {
        vm.prank(beneficiary);
        vm.expectRevert(AmiPay.InsufficientAllowance.selector);
        ap.spendFrom(sponsor, recipient, SPEND_AMOUNT);
    }

    function test_SpendFrom_SpendAllAllowance() public {
        // Setup: deposit allowance first
        vm.prank(sponsor);
        tt.approve(address(ap), DEPOSIT_AMOUNT);
        vm.prank(sponsor);
        ap.depositAllowance(beneficiary, DEPOSIT_AMOUNT);

        vm.prank(beneficiary);
        ap.spendFrom(sponsor, recipient, DEPOSIT_AMOUNT);

        assertEq(ap.allowances(beneficiary, sponsor), 0);
    }

    function test_SpendFrom_MultipleSpends() public {
        // Setup: deposit allowance first
        vm.prank(sponsor);
        tt.approve(address(ap), DEPOSIT_AMOUNT);
        vm.prank(sponsor);
        ap.depositAllowance(beneficiary, DEPOSIT_AMOUNT);

        uint256 firstSpend = SPEND_AMOUNT;
        uint256 secondSpend = SPEND_AMOUNT / 2;

        vm.prank(beneficiary);
        ap.spendFrom(sponsor, recipient, firstSpend);

        address recipient2 = address(0x5);
        vm.prank(beneficiary);
        ap.spendFrom(sponsor, recipient2, secondSpend);

        assertEq(
            ap.allowances(beneficiary, sponsor),
            DEPOSIT_AMOUNT - firstSpend - secondSpend
        );
    }

    function test_SpendFrom_EventEmitted() public {
        // Setup: deposit allowance first
        vm.prank(sponsor);
        tt.approve(address(ap), DEPOSIT_AMOUNT);
        vm.prank(sponsor);
        ap.depositAllowance(beneficiary, DEPOSIT_AMOUNT);

        vm.expectEmit(true, true, true, false);
        emit AmiPay.AllowanceSpent(
            sponsor,
            beneficiary,
            recipient,
            SPEND_AMOUNT
        );

        vm.prank(beneficiary);
        ap.spendFrom(sponsor, recipient, SPEND_AMOUNT);
    }

    function test_SpendFrom_WrongBeneficiary() public {
        // Setup: deposit allowance for beneficiary
        vm.prank(sponsor);
        tt.approve(address(ap), DEPOSIT_AMOUNT);
        vm.prank(sponsor);
        ap.depositAllowance(beneficiary, DEPOSIT_AMOUNT);

        // Try to spend as a different beneficiary
        address wrongBeneficiary = address(0x6);
        vm.prank(wrongBeneficiary);
        vm.expectRevert(AmiPay.InsufficientAllowance.selector);
        ap.spendFrom(sponsor, recipient, SPEND_AMOUNT);
    }

    function test_SpendFrom_MultipleSponsors() public {
        address sponsor2 = address(0x7);
        tt.mint(sponsor2, INITIAL_BALANCE);

        // Deposit from sponsor1
        vm.prank(sponsor);
        tt.approve(address(ap), DEPOSIT_AMOUNT);
        vm.prank(sponsor);
        ap.depositAllowance(beneficiary, DEPOSIT_AMOUNT);

        // Deposit from sponsor2
        vm.prank(sponsor2);
        tt.approve(address(ap), DEPOSIT_AMOUNT);
        vm.prank(sponsor2);
        ap.depositAllowance(beneficiary, DEPOSIT_AMOUNT);

        // Spend from sponsor1
        vm.prank(beneficiary);
        ap.spendFrom(sponsor, recipient, SPEND_AMOUNT);

        // Spend from sponsor2
        address recipient2 = address(0x8);
        vm.prank(beneficiary);
        ap.spendFrom(sponsor2, recipient2, SPEND_AMOUNT);

        assertEq(
            ap.allowances(beneficiary, sponsor),
            DEPOSIT_AMOUNT - SPEND_AMOUNT
        );
        assertEq(
            ap.allowances(beneficiary, sponsor2),
            DEPOSIT_AMOUNT - SPEND_AMOUNT
        );
    }

    // ============ Integration Tests ============

    function test_CompleteFlow() public {
        // Sponsor deposits allowance
        vm.prank(sponsor);
        tt.approve(address(ap), DEPOSIT_AMOUNT);
        vm.prank(sponsor);
        ap.depositAllowance(beneficiary, DEPOSIT_AMOUNT);

        // Beneficiary spends part of it
        vm.prank(beneficiary);
        ap.spendFrom(sponsor, recipient, SPEND_AMOUNT);

        // Sponsor deposits more
        vm.prank(sponsor);
        tt.approve(address(ap), DEPOSIT_AMOUNT);
        vm.prank(sponsor);
        ap.depositAllowance(beneficiary, DEPOSIT_AMOUNT);

        // Beneficiary spends again
        vm.prank(beneficiary);
        ap.spendFrom(sponsor, recipient, SPEND_AMOUNT);

        assertEq(
            ap.allowances(beneficiary, sponsor),
            DEPOSIT_AMOUNT * 2 - SPEND_AMOUNT * 2
        );
        assertEq(tt.balanceOf(recipient), SPEND_AMOUNT * 2);
    }
}
