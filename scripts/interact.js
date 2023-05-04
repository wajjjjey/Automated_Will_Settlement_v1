const hre = require("hardhat");

async function main() {
  const provider = network.provider;
  const CONTRACT_ADDRESS = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
  const accounts = await hre.ethers.getSigners();

  const WillProtocol = await hre.ethers.getContractFactory("WillProtocol");
  const willProtocol = WillProtocol.attach(CONTRACT_ADDRESS);

  const executors = [
    "0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f",
    "0xa0Ee7A142d267C1f36714E4a8F75612F20a79720",
  ];
  const assetNames = ["Chair", "Laptop"];
  const assetDescriptions = ["Brown mahogany, 18th century", "Dell", "Grey"];
  const nftRecipients = [
    "0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc",
    "0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65",
  ];
  const tokenAmounts = [50];
  const tokenAddresses = ["0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0"];
  const tokenRecipients = ["0x14dC79964da2C08b23698B3D3cc7Ca32193d9955"];

  const result = await willProtocol.createWill(
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
