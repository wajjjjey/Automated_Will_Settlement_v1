// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./WillProtocol.sol";
import "./TransferContract.sol";
import "/home/ubuntuwaj/node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "/home/ubuntuwaj/node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "/home/ubuntuwaj/node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract WillExecutor is ERC721, Ownable {
    address public willProtocol;
    WillProtocol private _willProtocol;

    mapping(address => TransferContract) public transferContracts;

    constructor() ERC721("PropertyTransferNFT", "PTR") {
        willProtocol = msg.sender;
        _willProtocol = WillProtocol(willProtocol);
    }

    function isReadyToExecute(address testator) public view returns (bool) {
        uint256 approvals = _willProtocol.countApprovals(testator);
        (uint256 executorsCount, ) = _willProtocol.getWillExecutorData(
            testator
        );
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

    /// Mint NFTs based on the info provided by testator to main contract
    function mintNFTs(address to, uint256[] memory nftTokenIds) public {
        require(msg.sender == willProtocol, "Only WillProtocol can mint NFTs");
        for (uint256 i = 0; i < nftTokenIds.length; i++) {
            _safeMint(to, nftTokenIds[i]);
        }
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
