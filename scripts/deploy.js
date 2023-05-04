// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
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

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
