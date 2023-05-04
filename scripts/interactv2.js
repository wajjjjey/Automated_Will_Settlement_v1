const hre = require("hardhat");

async function printWillInfo(willProtocol, testator) {
  const will = await willProtocol.getWill(testator);

  console.log("Will Information:");
  console.log("-----------------");
  console.log(
    "Executors:",
    will.executors ? will.executors.map((e) => e.toString()) : "N/A"
  );
  console.log(
    "Token Amounts:",
    will.tokenAmounts ? will.tokenAmounts.map((a) => a.toString()) : "N/A"
  );
  console.log(
    "Token Addresses:",
    will.tokenAddresses ? will.tokenAddresses.map((a) => a.toString()) : "N/A"
  );
  console.log(
    "Token Recipients:",
    will.tokenRecipients ? will.tokenRecipients.map((r) => r.toString()) : "N/A"
  );
  console.log(
    "NFT Recipients:",
    will.nftRecipients ? will.nftRecipients.map((r) => r.toString()) : "N/A"
  );
  console.log("-----------------\n");
}

async function main() {
  const [deployer, executor1, executor2, recipient1, recipient2] =
    await hre.ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  // Deploy BasicToken contract
  const BasicToken = await hre.ethers.getContractFactory("BasicToken");
  const initialSupply = hre.ethers.utils.parseUnits("1000000", 18);
  const basicToken = await BasicToken.deploy(initialSupply);
  await basicToken.deployed();

  // Deploy WillProtocol contract
  const WillProtocol = await hre.ethers.getContractFactory("WillProtocol");
  const willProtocol = await WillProtocol.deploy();
  await willProtocol.deployed();
  console.log("WillProtocol deployed to:", willProtocol.address);

  // Prepare the will data
  const executors = [executor1.address, executor2.address];
  const tokenAmounts = [100, 200];
  const tokenAddresses = [basicToken.address, basicToken.address];
  const tokenRecipients = [recipient1.address, recipient2.address];
  const assetNames = ["Asset1", "Asset2"];
  const assetDescriptions = ["Description1", "Description2"];
  const nftRecipients = [recipient1.address, recipient2.address];

  // Create the will
  await willProtocol.createWill(
    executors,
    tokenAmounts,
    tokenAddresses,
    tokenRecipients,
    assetNames,
    assetDescriptions,
    nftRecipients
  );
  console.log("Will created");
  await printWillInfo(willProtocol, deployer.address);

  // Executors submit their signatures
  await willProtocol
    .connect(executor1)
    .submitExecutorSignature(deployer.address);
  console.log("Executor1 signature submitted");
  await printWillInfo(willProtocol, deployer.address);

  await willProtocol
    .connect(executor2)
    .submitExecutorSignature(deployer.address);
  console.log("Executor2 signature submitted");
  await printWillInfo(willProtocol, deployer.address);

  // Check if the will is ready to execute
  const isReady = await willProtocol.isReadyToExecute(deployer.address);
  console.log("Is will ready to execute?", isReady);

  if (isReady) {
    // Execute the will
    await willProtocol.executeWill(deployer.address);
    console.log("Will executed");
  } else {
    console.log("Not enough signatures to execute the will");
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
