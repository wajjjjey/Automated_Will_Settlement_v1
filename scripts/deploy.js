const { EtherscanProvider } = require("@ethersproject/providers");
const { ethers } = require("hardhat");
const fs = require("fs-extra");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with teh account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  const WillProtocol = await ethers.getContractFactory("WillProtocol");
  const willProtocol = await WillProtocol.deploy();
  await willProtocol.deployed();

  console.log("WillProtocol deployed to:", willProtocol.address);
}

// async function main() {
//   /// RPC endpoint from test environment
//   const provider = new ethers.providers.JsonRpcProvider(
//     "HTTP://127.0.0.1:7545"
//   );

//   /// Choose a test environment wallet to deploy from and put private key here
//   const wallet = new ethers.Wallet(
//     "0xf80d19aa2061f536f5baa15e4591ac293863e8f43f2ee2deac8bacd3d4e2b074",
//     provider
//   );

//   /// get abi from contract file
//   const abi = fs.readFileSync(
//     "./Property_Transfer_Record_sol_Property_Transfer_Record.abi",
//     "utf8"
//   );
//   /// get binary from contract file
//   const binary = fs.readFileSync(
//     "/.Property_Transfer_Record_sol_Property_Transfer_Record.binary",
//     "utf8"
//   );
//   const contractFactory = new ethers.ContractFactory(abi, binary, wallet);
//   console.log("Deploying, please wait...");
//   const contract = await contractFactory.deploy();

//   /// Wait for further transactions to confirm finality of contract deploy
//   const deploymentReceipt = await contract.deploymentTransaction.wait(1);
//   console.log("Here is the deployment transaction: ");
//   console.log(contract.deploymentTransaction);
//   console.log("Here is the transaction receipt: ");
//   console.log(deploymentReceipt);
// }

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
