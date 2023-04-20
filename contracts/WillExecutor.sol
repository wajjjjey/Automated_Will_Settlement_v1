// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./WillProtocol.sol";
import "./TransferContract.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract WillExecutor is ERC721URIStorage, Ownable {
    address public willProtocol;
    WillProtocol private _willProtocol;

    /// NFT Token ID counter (subject to change/complication)
    uint256 private _currentTokenId;

    mapping(address => TransferContract) public transferContracts;

    constructor() ERC721("PropertyTransferNFT", "PTR") {
        willProtocol = msg.sender;
        _willProtocol = WillProtocol(willProtocol);
    }

    function isReadyToExecute(address testator) public view returns (bool) {
        uint256 approvals = _willProtocol.countApprovals(testator);
        uint256 executorsCount = _willProtocol.getWillExecutorData(testator);
        uint256 requiredApprovals = executorsCount - 1;
        return approvals >= requiredApprovals;
    }

    /// Create testator-specific transfer contract based on provided info to main contract
    function createTransferContract(
        uint256[] memory tokenAmounts,
        address[] memory tokenAddresses,
        address[] memory tokenRecipients,
        uint256[] memory nftTokenIds,
        address[] memory nftRecipients,
        address testator
    ) public returns (address) {
        require(
            msg.sender == willProtocol,
            "Only WillProtocol can create a TransferContract"
        );
        TransferContract newTransferContract = new TransferContract(
            address(this)
        );
        transferContracts[testator] = newTransferContract;
        newTransferContract.setTransferData(
            tokenAmounts,
            tokenAddresses,
            tokenRecipients,
            nftTokenIds,
            nftRecipients
        );
        return address(newTransferContract);
    }

    /// Mint NFTs based on the info provided by testator to main contract. Increase token counter on mint
    function mintNFTs(
        address to,
        string[] memory assetNames,
        string[] memory assetDescriptions
    ) public returns (uint256[] memory) {
        require(msg.sender == willProtocol, "Only WillProtocol can mint NFTs");
        uint256[] memory mintedTokenIds = new uint256[](assetNames.length);
        for (uint256 i = 0; i < assetNames.length; i++) {
            uint256 newTokenId = _currentTokenId;
            _safeMint(to, newTokenId);
            _setTokenURI(
                newTokenId,
                _generateTokenURI(assetNames[i], assetDescriptions[i])
            );
            mintedTokenIds[i] = newTokenId;
            _currentTokenId++;
        }
        return mintedTokenIds;
    }

    function preApproveNFTTransfer(uint256 tokenId, address recipient) public {
        require(
            msg.sender == willProtocol,
            "Only WillProtocol can pre-approve NFT transfers"
        );
        approve(recipient, tokenId);
    }

    /// Function to serve metadata in required JSON format. IPFS integration
    function _generateTokenURI(
        string memory assetNames,
        string memory assetDescriptions
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    'data:application/json;base64,{"name":"',
                    assetNames,
                    '","description":"',
                    assetDescriptions,
                    '"}'
                )
            );
    }

    /// Execute transfers in transfer contract when enough signatures received to main contract
    function executeTransfers(address testator) public onlyOwner {
        require(isReadyToExecute(testator), "Not enough sigantures");

        address transferContractAddress = address(transferContracts[testator]);
        TransferContract transferContract = TransferContract(
            transferContractAddress
        );
        transferContract.executeTransfers();
    }
}
