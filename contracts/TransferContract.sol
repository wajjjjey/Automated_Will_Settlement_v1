// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./WillProtocol.sol";
import "./WillExecutor.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TransferContract is Ownable {
    address[] private _tokenAddresses;
    uint256[] private _tokenAmounts;
    address[] private _tokenRecipients;

    address[] private _nftRecipients;
    uint256[] private _nftTokenIds;

    IERC721 private _nftContract;

    bool private _executed;

    constructor(address nftContractAddress) {
        _nftContract = IERC721(nftContractAddress);
    }

    function setTransferData(
        uint256[] memory tokenAmounts,
        address[] memory tokenAddresses,
        address[] memory tokenRecipients,
        uint256[] memory nftTokenIds,
        address[] memory nftRecipients
    ) external onlyOwner {
        _tokenAmounts = tokenAmounts;
        _tokenAddresses = tokenAddresses;
        _tokenRecipients = tokenRecipients;
        _nftTokenIds = nftTokenIds;
        _nftRecipients = nftRecipients;
    }

    function executeTransfers() external onlyOwner {
        require(!_executed, "Transfers already executed");

        WillProtocol willProtocol = WillProtocol(owner());
        WillExecutor willExecutor = willProtocol.willExecutor();
        require(
            willExecutor.isReadyToExecute(owner()),
            "Not enough executor signatures"
        );

        // Transfer tokens
        for (uint256 i = 0; i < _tokenAddresses.length; i++) {
            IERC20 token = IERC20(_tokenAddresses[i]);
            token.transferFrom(owner(), _tokenRecipients[i], _tokenAmounts[i]);
        }

        // Transfer NFTS
        for (uint256 i = 0; i < _nftTokenIds.length; i++) {
            _nftContract.transferFrom(
                owner(),
                _nftRecipients[i],
                _nftTokenIds[i]
            );
        }

        _executed = true;
    }
}
