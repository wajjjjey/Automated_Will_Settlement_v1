const { ethers } = require("hardhat");

async function main() {
  const CONTRACT_ADDRESS = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
  const WillProtocol = await ethers.getContractFactory("WillProtocol");
  const provider = (await ethers.getSigners())[0].provider;
  const willProtocol = new ethers.Contract(
    CONTRACT_ADDRESS,
    WillProtocol.interface,
    provider
  );

  const executors = [
    "0xdD2FD4581271e230360230F9337D5c0430Bf44C0",
    "0xbDA5747bFD65F08deb54cb465eB87D40e51B197E",
  ];
  const assetNames = ["Chair", "Laptop"];
  const assetDescriptions = ["Brown mahogany, 18th century", "Dell"];
  const nftRecipients = ["0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199"];
  const tokenAmounts = [50];
  const tokenAddresses = ["0x5FbDB2315678afecb367f032d93F642f64180aa3"];
  const tokenRecipients = ["0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199"];

  const signer = (await ethers.getSigners())[0];

  const result = await willProtocol
    .connect(signer)
    .createWill(
      executors,
      assetNames,
      assetDescriptions,
      nftRecipients,
      tokenAmounts,
      tokenAddresses,
      tokenRecipients
    );

  const receipt = await result.wait();
  console.log("Transaction receipt:", receipt);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
