import { task } from "hardhat/config";
import { getContractAt } from "@nomicfoundation/hardhat-viem/helpers";
import { parseEther } from "viem";

task("deposit", "Deposit allowance to a beneficiary")
    .addParam("contract", "AmiPay contract address")
    .addParam("beneficiary", "Beneficiary address")
    .addParam("amount", "Amount to deposit (in token units, e.g., 1000000 for 1 USDC with 6 decimals)")
    .setAction(async (taskArgs, hre) => {
        const { viem } = await hre.network.connect();
        const [account] = await viem.getWalletClients();

        const amiPay = await getContractAt("AmiPay", taskArgs.contract);
        const token = await getContractAt("TestToken", await amiPay.read.supportToken());

        const amount = BigInt(taskArgs.amount);

        console.log(`Approving ${taskArgs.amount} tokens...`);
        const approveTx = await token.write.approve([taskArgs.contract, amount], {
            account: account.account,
        });
        await viem.getPublicClient().waitForTransactionReceipt({ hash: approveTx });
        console.log("Approval confirmed");

        console.log(`Depositing allowance for beneficiary ${taskArgs.beneficiary}...`);
        const depositTx = await amiPay.write.depositAllowance([taskArgs.beneficiary, amount], {
            account: account.account,
        });
        const receipt = await viem.getPublicClient().waitForTransactionReceipt({ hash: depositTx });
        console.log(`Allowance deposited! Transaction: ${receipt.transactionHash}`);

        const allowance = await amiPay.read.allowances([taskArgs.beneficiary, account.account.address]);
        console.log(`Current allowance: ${allowance.toString()}`);
    });

task("spend", "Spend from allowance")
    .addParam("contract", "AmiPay contract address")
    .addParam("sponsor", "Sponsor address")
    .addParam("recipient", "Recipient address")
    .addParam("amount", "Amount to spend (in token units)")
    .setAction(async (taskArgs, hre) => {
        const { viem } = await hre.network.connect();
        const [account] = await viem.getWalletClients();

        const amiPay = await getContractAt("AmiPay", taskArgs.contract);
        const amount = BigInt(taskArgs.amount);

        console.log(`Spending ${taskArgs.amount} from sponsor ${taskArgs.sponsor} to ${taskArgs.recipient}...`);
        const spendTx = await amiPay.write.spendFrom(
            [taskArgs.sponsor, taskArgs.recipient, amount],
            { account: account.account }
        );
        const receipt = await viem.getPublicClient().waitForTransactionReceipt({ hash: spendTx });
        console.log(`Spent successfully! Transaction: ${receipt.transactionHash}`);

        const allowance = await amiPay.read.allowances([account.account.address, taskArgs.sponsor]);
        console.log(`Remaining allowance: ${allowance.toString()}`);
    });

task("allowance", "Check allowance for a beneficiary from a sponsor")
    .addParam("contract", "AmiPay contract address")
    .addParam("beneficiary", "Beneficiary address")
    .addParam("sponsor", "Sponsor address")
    .setAction(async (taskArgs, hre) => {
        const { viem } = await hre.network.connect();

        const amiPay = await getContractAt("AmiPay", taskArgs.contract);
        const allowance = await amiPay.read.allowances([taskArgs.beneficiary, taskArgs.sponsor]);

        console.log(`Allowance for beneficiary ${taskArgs.beneficiary} from sponsor ${taskArgs.sponsor}:`);
        console.log(`${allowance.toString()} tokens`);
    });

task("balance", "Check token balance of an address")
    .addParam("token", "Token contract address")
    .addParam("address", "Address to check")
    .setAction(async (taskArgs, hre) => {
        const { viem } = await hre.network.connect();

        const token = await getContractAt("TestToken", taskArgs.token);
        const balance = await token.read.balanceOf([taskArgs.address]);

        console.log(`Balance of ${taskArgs.address}:`);
        console.log(`${balance.toString()} tokens`);
    });

