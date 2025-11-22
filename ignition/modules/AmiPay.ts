import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("AmiPayModule", (m) => {
  // Deploy TestToken first
  const testToken = m.contract("TestToken");

  // Deploy AmiPay with TestToken's address as constructor parameter
  const amiPay = m.contract("AmiPay", [testToken]);

  return { testToken, amiPay };
});
