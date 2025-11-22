# Hardhat 3 Prize Submission - Feature Showcase

This document highlights all the Hardhat 3 features used in this project to qualify for the **Hardhat Prize** at ETHGlobal Argentina 2025.

## ✅ Prize Requirement

> **Build your project using Hardhat 3 as the main Solidity testing and network simulation tool**

## 🎯 Hardhat 3 Features Implemented

### 1. Dual Testing Approach

Hardhat 3 supports both Foundry-style Solidity tests and TypeScript/Viem tests:

- **Solidity Tests** (`contracts/AmiPay.t.sol`):
  - Uses `forge-std/Test.sol` (Foundry compatibility)
  - Comprehensive test coverage with 20+ test cases
  - Includes Hardhat console logging examples
  - Run with: `npx hardhat test solidity`

- **TypeScript Tests** (`test/AmiPay.test.ts`):
  - Uses Hardhat's Viem integration
  - Demonstrates TypeScript testing capabilities
  - Run with: `npx hardhat test test/`

### 2. EDR (Ethereum Development Runtime) Network Simulation

Hardhat 3's advanced network simulation capabilities:

- **L1 Network Simulation** (`hardhatMainnet`):
  - Configured in `hardhat.config.ts`
  - Tested in `test/edr-network.test.ts`
  - Simulates mainnet-like environment

- **Optimism Network Simulation** (`hardhatOp`):
  - Configured with `chainType: "op"`
  - Includes L1 gas estimation testing
  - Demonstrates L2-specific features

- **Network Simulation Script** (`scripts/send-op-tx.ts`):
  - Shows practical usage of EDR networks
  - Demonstrates L1 gas estimation on Optimism

### 3. Hardhat Ignition 3 for Deployment

- **Declarative Deployment** (`ignition/modules/AmiPay.ts`):
  - Module-based deployment configuration
  - Automatic dependency management
  - Supports multiple networks

- **Deployment Examples**:
  - Local network: `npx hardhat ignition deploy ignition/modules/AmiPay.ts --network localhost`
  - Testnet: `npx hardhat ignition deploy ignition/modules/AmiPay.ts --network hoodi`
  - EDR simulation: `npx hardhat ignition deploy ignition/modules/AmiPay.ts --network hardhatMainnet`

### 4. Custom Hardhat Tasks

Four custom tasks for common operations (`tasks/index.ts`):

1. **`npx hardhat deposit`** - Deposit allowance to a beneficiary
2. **`npx hardhat spend`** - Spend from allowance
3. **`npx hardhat allowance`** - Check allowance between beneficiary and sponsor
4. **`npx hardhat balance`** - Check token balance

These tasks demonstrate:
- Viem integration
- Contract interaction patterns
- Error handling
- Transaction receipt waiting

### 5. Gas Reporting

- Configured in `hardhat.config.ts`
- Enabled with `REPORT_GAS=true` environment variable
- Outputs to `gas-report.txt`
- Helps with gas optimization analysis

### 6. Hardhat Console Logging

- Used in Solidity tests (`contracts/AmiPay.t.sol`)
- Demonstrates debugging capabilities
- Example in `test_DepositAllowance_Success()`

### 7. Network Configuration

Comprehensive network setup in `hardhat.config.ts`:

- **EDR Networks**:
  - `hardhatMainnet` (L1 simulation)
  - `hardhatOp` (Optimism simulation)

- **Testnet Networks**:
  - `sepolia` (Ethereum testnet)
  - `hoodi` (Custom testnet)

- **Features**:
  - Config variables for sensitive data
  - Etherscan verification support
  - Multiple chain types

## 📊 Test Coverage

- **Solidity Tests**: 20+ test cases covering all contract functions
- **TypeScript Tests**: Additional test suite with Viem
- **EDR Network Tests**: Specific tests for network simulation
- **Coverage Report**: Available via `npx hardhat test solidity --coverage`

## 🚀 How to Verify

1. **Run all tests**:
   ```bash
   npx hardhat test
   ```

2. **Run Solidity tests**:
   ```bash
   npx hardhat test solidity
   ```

3. **Run TypeScript tests**:
   ```bash
   npx hardhat test test/
   ```

4. **Run EDR network simulation tests**:
   ```bash
   npx hardhat test test/edr-network.test.ts
   ```

5. **Test custom tasks**:
   ```bash
   npx hardhat deposit --help
   npx hardhat spend --help
   ```

6. **Deploy using Ignition**:
   ```bash
   npx hardhat ignition deploy ignition/modules/AmiPay.ts --network hardhatMainnet
   ```

## 📝 Key Files

- `hardhat.config.ts` - Hardhat 3 configuration with EDR networks
- `contracts/AmiPay.t.sol` - Solidity test suite (Foundry-compatible)
- `test/AmiPay.test.ts` - TypeScript test suite (Viem)
- `test/edr-network.test.ts` - EDR network simulation tests
- `tasks/index.ts` - Custom Hardhat tasks
- `ignition/modules/AmiPay.ts` - Deployment configuration
- `scripts/send-op-tx.ts` - EDR network usage example

## ✨ Why This Qualifies

1. ✅ **Hardhat 3** is the primary testing framework
2. ✅ **Dual testing approach** (Solidity + TypeScript)
3. ✅ **EDR network simulation** extensively used
4. ✅ **Hardhat Ignition 3** for deployments
5. ✅ **Custom tasks** for developer experience
6. ✅ **Comprehensive test coverage**
7. ✅ **Gas reporting** configured
8. ✅ **Production-ready** deployment setup

This project demonstrates a **complete and advanced** use of Hardhat 3's capabilities, going beyond basic requirements to showcase the full power of the framework.

