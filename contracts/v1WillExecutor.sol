// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./TransferContract.sol";
import "/home/ubuntuwaj/node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "/home/ubuntuwaj/node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "/home/ubuntuwaj/node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract WillExecutor is ERC721, Ownable {
    address public willProtocol;
    uint256 public nftCounter;
    mapping(uint256 => bool) public preApprovedNFTTransfer;
    mapping(uint256 => address) public nftRecipients;
    mapping(uint256 => string) private _tokenURIs;

    /// Token transfer
    struct TokenTransfer {
        address token;
        uint256 amount;
        address recipient;
        bool isApproved;
    }

    TokenTransfer[] public tokenTransfers;

    constructor(address _willProtocol) ERC721("PropertyTransferNFT", "PTR") {
        willProtocol = _willProtocol;
    }


    function setupTokenTransfer(
        address _token,
        uint256 _amount,
        address _recipient
    ) public onlyOwner {
        TokenTransfer memory newTransfer = TokenTransfer({
            token: _token,
            amount: _amount,
            recipient: _recipient,
            isApproved: true
        });

        tokenTransfers.push(newTransfer);
    }

    function executeTokenTransfer(uint256 _transferIndex) public {
        require(
            msg.sender == willProtocol,
            "Only WillProtocol can execute transfers on confirmation of Will Owner's death"
        );
        TokenTransfer storage transfer = tokenTransfers[_transferIndex];
        require(transfer.isApproved, "Transfer is not pre-approved");

        IERC20 token = IERC20(transfer.token);
        require(
            token.transferFrom(owner(), transfer.recipient, transfer.amount),
            "Token transfer failed"
        );
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        require(
            _exists(tokenId),
            "ERC721URIStorage: URI query for nonexistent token"
        );
        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        if (bytes(base).length == 0) {
            return _tokenURI;
        }

        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    function mintNFT(address to, string memory tokenMetadata) public onlyOwner {
        uint256 tokenId = nftCounter;
        _mint(to, tokenId);
        _tokenURIs[tokenId] = tokenMetadata;
        nftCounter++;
    }

    function preApproveNFTTransfer(
        uint256 tokenId,
        address recipient
    ) public onlyOwner {
        preApprovedNFTTransfer[tokenId] = true;
        nftRecipients[tokenId] = recipient;
    }

    function executeNFTTransfer(uint256 tokenId) public {
        require(
            msg.sender == willProtocol,
            "Only WillProtocol can execute transfers on confirmation of Will Owner's death"
        );
        require(preApprovedNFTTransfer[tokenId], "Transfer not pre-approved");
        address recipient = nftRecipients[tokenId];
        _transfer(ownerOf(tokenId), recipient, tokenId);
    }
}
