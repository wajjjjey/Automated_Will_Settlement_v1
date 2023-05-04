const { etheres, ethers } = require("hardhat");

async function main() {
  const BasicToken = await ethers.getContractFactory("BasicToken");
  const initialSupply = ethers.utils.parseEther("1000");
  const basicToken = await BasicToken.deploy(initialSupply);

  await basicToken.deployed();

  console.log("MyToken deployed to:", basicToken.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
