// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./WillExecutor.sol";

contract WillProtocol is Ownable, ERC165, IERC721Receiver {
    WillExecutor private _willExecutor;

    struct Will {
        bool isConfirmed;
        address[] executors;
        uint256[] tokenAmounts;
        address[] tokenAddresses;
        address[] tokenRecipients;
        address[] nftRecipients;
        uint256[] nftTokenIds;
    }

    struct Confirmation {
        uint256 count;
        mapping(address => bool) signatures;
    }

    mapping(address => Will) public wills;
    mapping(address => Confirmation) public confirmations;
    mapping(address => WillExecutor) public executorContract;
    mapping(address => mapping(address => bool)) public executorSignatures;

    /// On deployment, creates 1x WillExecutor contract & assigns ownership to WillProtocol
    constructor() {
        _willExecutor = new WillExecutor(address(this));
        _willExecutor.transferOwnership(address(this));
    }

    /// Returns the instance of Will Executor contract for interaction through this contract
    function willExecutor() public view returns (WillExecutor) {
        return _willExecutor;
    }

    function createWill(
        address[] memory _executors,
        uint256[] memory _tokenAmounts,
        address[] memory _tokenAddresses,
        address[] memory _tokenRecipients,
        string[] memory assetNames,
        string[] memory assetDescriptions,
        address[] memory _nftRecipients
    ) public {
        require(
            wills[msg.sender].isConfirmed == false,
            "Will already exists and confirmed"
        );
        wills[msg.sender] = Will({
            isConfirmed: false,
            executors: _executors,
            tokenAmounts: _tokenAmounts,
            tokenAddresses: _tokenAddresses,
            tokenRecipients: _tokenRecipients,
            nftTokenIds: new uint256[](0),
            nftRecipients: _nftRecipients
        });

        // Preapprove ERC-20 token transfers
        for (uint256 i = 0; i < _tokenAddresses.length; i++) {
            IERC20(_tokenAddresses[i]).approve(
                address(_willExecutor),
                _tokenAmounts[i]
            );
        }

        // Mint NFTs and pre-approve their transfers
        uint256[] memory mintedTokenIds = willExecutor().mintNFTs(
            address(this),
            assetNames,
            assetDescriptions
        );

        // Set approval for all tokens from the user to the WillProtocol contract
        IERC721(address(_willExecutor)).setApprovalForAll(msg.sender, true);

        for (uint256 i = 0; i < mintedTokenIds.length; i++) {
            willExecutor().preApproveNFTTransfer(
                mintedTokenIds[i],
                _nftRecipients[i]
            );
        }
    }

    /// Execute transfers once n-1 executor signatures received
    /// Call `executeTransfers` in `WillExecutor`
    /// Pass testators address as an argument in the above
    function executeWill(address testator) public {
        Will storage will = wills[testator];
        require(will.isConfirmed, "Will not confirmed");
        require(isExecutor(msg.sender, testator), "Not authorized");

        _willExecutor.executeTransfers(testator);

        delete wills[testator];
    }

    function recoverSigner(
        bytes32 _hash,
        bytes memory _signature
    ) private pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(_signature, 0x20))
            s := mload(add(_signature, 0x40))
            v := byte(0, mload(add(_signature, 0x60)))
        }

        return ecrecover(_hash, v, r, s);
    }

    function submitExecutorSignature(address testator) public {
        require(isExecutor(msg.sender, testator), "Caller is not an executor");
        executorSignatures[testator][msg.sender] = true;

        uint256 approvals = countApprovals(testator);
        if (approvals == wills[testator].executors.length - 1) {
            executeWill(testator);
        }
    }

    function countApprovals(address testator) public view returns (uint256) {
        uint256 approvals = 0;
        for (uint256 i = 0; i < wills[testator].executors.length; i++) {
            if (executorSignatures[testator][wills[testator].executors[i]]) {
                approvals++;
            }
        }
        return approvals;
    }

    function isExecutor(
        address executor,
        address testator
    ) private view returns (bool) {
        Will storage will = wills[testator];
        for (uint256 i = 0; i < will.executors.length; i++) {
            if (will.executors[i] == executor) {
                return true;
            }
        }
        return false;
    }

    // Custom getter function for WillExecutor

    function getWillExecutorData(
        address testator
    ) public view returns (uint256) {
        Will storage will = wills[testator];
        return will.executors.length;
    }

    /// ERC721 Receiver
    function onERC721Received(
        address /* operator */,
        address /* from */,
        uint256 /* tokenId */,
        bytes calldata /* data */
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    /// Getter functions for testing
    function getWillExecutors(
        address testator
    ) public view returns (address[] memory) {
        return wills[testator].executors;
    }

    function getWill(address testator) public view returns (Will memory) {
        return wills[testator];
    }

    function getWillTokenAmounts(
        address testator
    ) public view returns (uint256[] memory) {
        return wills[testator].tokenAmounts;
    }

    function getWillTokenAddresses(
        address testator
    ) public view returns (address[] memory) {
        return wills[testator].tokenAddresses;
    }

    function getWillTokenRecipients(
        address testator
    ) public view returns (address[] memory) {
        return wills[testator].tokenRecipients;
    }

    function getWillNftRecipients(
        address testator
    ) public view returns (address[] memory) {
        return wills[testator].nftRecipients;
    }

    function getWillNftTokenIds(
        address testator
    ) public view returns (uint256[] memory) {
        return wills[testator].nftTokenIds;
    }
}
