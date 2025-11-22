# AmiPay 💸

**Let your amigos help you pay.**

A decentralized payment solution built during ETHGlobal Argentina 2025, inspired by the local payment app "Peanut" and designed to solve KYC barriers for international travelers.

## 🌎 Our Story

We came to Argentina for DevConnect and ETHGlobal Argentina, and we absolutely fell in love with this place! During our stay, we discovered "Peanut" - a local payment app that does an amazing job supporting both fiat money and crypto payments.

However, we noticed there's still room for improvement. As the citizens from like China, we experienced the difficulty of passing KYC processes, which prevented us from paying at restaurants and shops. This inspired us to build **AmiPay** during the hackathon.

## 🎯 The Problem

For many international travelers, especially those from certain regions, KYC verification can be a significant barrier to accessing payment services. This creates a frustrating experience when trying to pay for everyday expenses like meals and shopping.

## 💡 Our Solution

**AmiPay** enables amigos (your friends) who can pass KYC to deposit an allowance for you. When you need to pay, you can use this pre-funded allowance.

### How It Works

1. **Sponsor Deposits**: A friend (sponsor) who has passed KYC deposits tokens into the AmiPay smart contract, specifying you as the beneficiary
2. **You Spend**: When you need to pay, you can spend from the allowance your friend deposited
3. **Direct Transfer**: The payment goes directly from the smart contract to the merchant/recipient

All of this is managed transparently on-chain through our smart contract, ensuring trust and security.

## 🏗️ Architecture

### Smart Contract (`AmiPay.sol`)

The core smart contract manages allowances between sponsors and beneficiaries:

- **`depositAllowance(beneficiary, amount)`**: Allows a sponsor to deposit tokens for a beneficiary
- **`spendFrom(sponsor, recipient, amount)`**: Allows a beneficiary to spend from a sponsor's deposited allowance
- **`allowances[beneficiary][sponsor]`**: Public mapping to query available allowances

### Frontend

A React-based mobile-friendly web application featuring:

- Wallet connection via RainbowKit
- QR code scanning for payments
- Real-time balance display
- Sponsor management interface
- Transaction history

## 🛠️ Tech Stack

### Smart Contracts

- **Solidity** ^0.8.28
- **Hardhat3** for development and testing
- **OpenZeppelin** contracts for security
- **Hardhat Ignition** for deployment

### Frontend

- **React** 19 with **TypeScript**
- **Vite** for build tooling
- **Wagmi** & **Viem** for Ethereum interactions
- **RainbowKit** for wallet connection
- **React QR Scanner** for payment scanning

## 📁 Project Structure

```
ami-pay/
├── contracts/          # Solidity smart contracts
│   ├── AmiPay.sol     # Main contract
│   └── TestToken.sol  # Test ERC20 token
├── frontend/          # React frontend application
│   └── src/
│       ├── App.tsx    # Main app component
│       ├── components/
│       └── chainConfig.ts
├── scripts/           # Deployment and utility scripts
├── ignition/          # Hardhat Ignition deployment configs
└── hardhat.config.ts  # Hardhat configuration
```


## 🧪 Testing

Run the test suite:

```bash
npx hardhat test
```


## 📄 License

This project is built for ETHGlobal Argentina 2025 hackathon.

## 🙏 Acknowledgments

- Inspired by **Peanut** - the amazing local payment app in Argentina
- Built with ❤️ during **ETHGlobal Argentina 2025**
- Special thanks to the DevConnect and ETHGlobal communities

---

**Made with precious memories in Argentina 🇦🇷**
