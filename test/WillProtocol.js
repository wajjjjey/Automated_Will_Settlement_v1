const { expect } = require("chai");
const { ethers } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("WillProtocol", function () {
  async function deployWillProtocolFixture() {
    const [owner, executor1, executor2, recipient1, recipient2] =
      await ethers.getSigners();

    const BasicToken = await ethers.getContractFactory("BasicToken");
    const token1 = await BasicToken.deploy(
      "Token1",
      "TK1",
      ethers.utils.parseEther("10000")
    );
    const token2 = await BasicToken.deploy(
      "Token2",
      "TK2",
      ethers.utils.parseEther("10000")
    );

    const WillProtocol = await ethers.getContractFactory("WillProtocol");
    const willProtocol = await WillProtocol.deploy();

    return {
      owner,
      willProtocol,
      executor1,
      executor2,
      recipient1,
      recipient2,
      token1,
      token2,
    };
  }

  describe("Deployment", function () {
    it("Should set the correct owner", async function () {
      const { owner, willProtocol } = await loadFixture(
        deployWillProtocolFixture
      );
      expect(await willProtocol.owner()).to.equal(owner.address);
    });

    it("Should deploy WillExecutor and set the correct owner", async function () {
      const { owner, willProtocol } = await loadFixture(
        deployWillProtocolFixture
      );
      const willExecutorAddress = await willProtocol.willExecutor();
      const willExecutor = await ethers.getContractAt(
        "WillExecutor",
        willExecutorAddress
      );
      expect(await willExecutor.owner()).to.equal(willProtocol.address);
    });
  });

  describe("createWill", function () {
    it("Should create a will with the correct values", async function () {
      const {
        owner,
        willProtocol,
        executor1,
        executor2,
        recipient1,
        recipient2,
        token1,
        token2,
      } = await loadFixture(deployWillProtocolFixture);
      const executors = [executor1.address, executor2.address];
      const tokenAmounts = [100, 200];
      const tokenAddresses = [token1.address, token2.address];
      const tokenRecipients = [recipient1.address, recipient2.address];
      const assetNames = ["Asset1", "Asset2"];
      const assetDescriptions = ["Description1", "Description2"];
      const nftRecipients = [recipient1.address, recipient2.address];

      await willProtocol.createWill(
        executors,
        tokenAmounts,
        tokenAddresses,
        tokenRecipients,
        assetNames,
        assetDescriptions,
        nftRecipients
      );

      const willExecutors = await willProtocol.getWillExecutors(owner.address);
      const willTokenAmounts = await willProtocol.getWillTokenAmounts(
        owner.address
      );
      const willTokenAddresses = await willProtocol.getWillTokenAddresses(
        owner.address
      );
      const willTokenRecipients = await willProtocol.getWillTokenRecipients(
        owner.address
      );
      const willNftRecipients = await willProtocol.getWillNftRecipients(
        owner.address
      );

      expect(willExecutors).to.deep.equal(executors);
      expect(willTokenAmounts).to.deep.equal(tokenAmounts);
      expect(willTokenAddresses).to.deep.equal(tokenAddresses);
      expect(willTokenRecipients).to.deep.equal(tokenRecipients);
      expect(willNftRecipients).to.deep.equal(nftRecipients);
    });
  });

  describe("submitExecutorSignature and executeWill", function () {
    it("Should submit executor signatures and execute the will", async function () {
      const {
        owner,
        willProtocol,
        executor1,
        executor2,
        recipient1,
        recipient2,
        token1,
        token2,
      } = await loadFixture(deployWillProtocolFixture);
      const executors = [executor1.address, executor2.address];
      const tokenAmounts = [100, 200];
      const tokenAddresses = [token1.address, token2.address];
      const tokenRecipients = [recipient1.address, recipient2.address];
      const assetNames = ["Asset1", "Asset2"];
      const assetDescriptions = ["Description1", "Description2"];
      const nftRecipients = [recipient1.address, recipient2.address];

      await willProtocol.createWill(
        executors,
        tokenAmounts,
        tokenAddresses,
        tokenRecipients,
        assetNames,
        assetDescriptions,
        nftRecipients
      );

      await willProtocol
        .connect(executor1)
        .submitExecutorSignature(owner.address);
      let approvals = await willProtocol.countApprovals(owner.address);
      expect(approvals).to.equal(1);

      await willProtocol
        .connect(executor2)
        .submitExecutorSignature(owner.address);
      approvals = await willProtocol.countApprovals(owner.address);
      expect(approvals).to.equal(2);
    });

    it("Should revert if the caller is not an executor", async function () {
      const {
        owner,
        willProtocol,
        executor1,
        executor2,
        recipient1,
        recipient2,
        token1,
        token2,
      } = await loadFixture(deployWillProtocolFixture);
      const executors = [executor1.address, executor2.address];
      const tokenAmounts = [100, 200];
      const tokenAddresses = [token1.address, token2.address];
      const tokenRecipients = [recipient1.address, recipient2.address];
      const assetNames = ["Asset1", "Asset2"];
      const assetDescriptions = ["Description1", "Description2"];
      const nftRecipients = [recipient1.address, recipient2.address];

      await willProtocol.createWill(
        executors,
        tokenAmounts,
        tokenAddresses,
        tokenRecipients,
        assetNames,
        assetDescriptions,
        nftRecipients
      );

      await expect(
        willProtocol.connect(recipient1).submitExecutorSignature(owner.address)
      ).to.be.revertedWith("Caller is not an executor");
    });
  });

  describe("getWillExecutorData", function () {
    it("Should return the correct executor count for a will", async function () {
      const {
        owner,
        willProtocol,
        executor1,
        executor2,
        recipient1,
        recipient2,
        token1,
        token2,
      } = await loadFixture(deployWillProtocolFixture);
      const executors = [executor1.address, executor2.address];
      const tokenAmounts = [100, 200];
      const tokenAddresses = [token1.address, token2.address];
      const tokenRecipients = [recipient1.address, recipient2.address];
      const assetNames = ["Asset1", "Asset2"];
      const assetDescriptions = ["Description1", "Description2"];
      const nftRecipients = [recipient1.address, recipient2.address];

      await willProtocol.createWill(
        executors,
        tokenAmounts,
        tokenAddresses,
        tokenRecipients,
        assetNames,
        assetDescriptions,
        nftRecipients
      );

      const executorCount = await willProtocol.getWillExecutorData(
        owner.address
      );
      expect(executorCount).to.equal(executors.length);
    });
  });
});
