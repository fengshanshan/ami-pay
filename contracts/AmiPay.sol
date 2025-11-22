// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AmiPay {
    /// @notice ERC20 token that can be deposited by sponsors to fund beneficiaries.
    IERC20 public immutable supportToken;

    /// @notice allowances[beneficiary][sponsor] => amount that beneficiary can spend from sponsor.
    mapping(address => mapping(address => uint256)) public allowances;

    error InvalidAddress();
    error InvalidAmount();
    error InsufficientAllowance();

    event AllowanceDeposited(
        address indexed sponsor,
        address indexed beneficiary,
        uint256 amount
    );
    event AllowanceSpent(
        address indexed sponsor,
        address indexed beneficiary,
        address indexed recipient,
        uint256 amount
    );

    constructor(address _support_token) {
        if (_support_token == address(0)) revert InvalidAddress();
        supportToken = IERC20(_support_token);
    }

    /// @notice Sponsor deposits tokens that a beneficiary will be able to spend later.
    /// @param beneficiary Address that will be able to spend the allowance.
    /// @param amount Amount of tokens deposited.
    function depositAllowance(address beneficiary, uint256 amount) external {
        if (beneficiary == address(0)) revert InvalidAddress();
        if (amount == 0) revert InvalidAmount();

        supportToken.transferFrom(msg.sender, address(this), amount);
        allowances[beneficiary][msg.sender] += amount;

        emit AllowanceDeposited(msg.sender, beneficiary, amount);
    }

    /// @notice Beneficiary spends tokens from a sponsor to a recipient.
    /// @param sponsor Address that funded the allowance.
    /// @param recipient Address that will receive the tokens.
    /// @param amount Amount of tokens to transfer.
    function spendFrom(
        address sponsor,
        address recipient,
        uint256 amount
    ) external {
        if (recipient == address(0)) revert InvalidAddress();
        if (amount == 0) revert InvalidAmount();

        uint256 allowance = allowances[msg.sender][sponsor];
        if (allowance < amount) revert InsufficientAllowance();

        allowances[msg.sender][sponsor] = allowance - amount;
        supportToken.transfer(recipient, amount);

        emit AllowanceSpent(sponsor, msg.sender, recipient, amount);
    }
}
