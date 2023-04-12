const ethers = require("ethers");
const fs = require("fs-extra");

async function main() {
  /// RPC endpoint from test environment
  const provider = new ethers.providers.JsonRpcProvider(
    "HTTP://127.0.0.1:7545"
  );

  /// Choose a test environment wallet to deploy from and put private key here
  const wallet = new ethers.Wallet(
    "0xf4c66989271d56b6a85c0b4dfdf818f236b10045b113d61653b76ab4fc352b39",
    provider
  );

  /// get abi from contract file
  const abi = fs.readFileSync(
    "./Property_Transfer_Record_sol_Property_Transfer_Record.abi",
    "utf8"
  );
  /// get binary from contract file
  const binary = fs.readFileSync(
    "/.Property_Transfer_Record_sol_Property_Transfer_Record.binary",
    "utf8"
  );
  const contractFactory = new ethers.ContractFactory(abi, binary, wallet);
  console.log("Deploying, please wait...");
  const contract = await contractFactory.deploy();

  /// Wait for further transactions to confirm finality of contract deploy
  const deploymentReceipt = await contract.deploymentTransaction.wait(1);
  console.log("Here is the deployment transaction: ");
  console.log(contract.deploymentTransaction);
  console.log("Here is the transaction receipt: ");
  console.log(deploymentReceipt);

  /// Send a transaction on deployment with custom values.
  /// Eventually want to make this so new transactions created and signed by contract owner
  /// and then they are sent once multi-sig conf
  //   const nonce = await wallet.getTransactionCount();
  //   const tx = {
  //     nonce: nonce,
  //     gasPrice:
  //     gasLimit:
  //     to:
  //     value:
  //     data:
  //     chainId:
  //   };
  //   const sentTxResponse = await wallet.sendTransactiontx();
  //   await sentTxResponse.wait(1);
  //   console.log(sentTxResponse);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
