// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./TransferContract.sol";
import "/home/ubuntuwaj/node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "./WillExecutor.sol";

contract WillProtocol is Ownable {
    WillExecutor private _willExecutor;

    struct Will {
        bool isConfirmed;
        address[] executors;
        uint256[] tokenAmounts;
        address[] tokenAddresses;
        address[] tokenRecipients;
        uint256[] tokenIds;
        uint256[] nftTokenIds;
        address[] nftRecipients;
    }

    struct Confirmation {
        uint256 count;
        mapping(address => bool) signatures;
    }

    mapping(address => Will) public wills;
    mapping(address => Confirmation) public confirmations;
    mapping(address => WillExecutor) public executorContract;
    mapping(address => mapping(address => bool)) public executorSignatures;

    /// On deployment, creates 1x WillExecutor contract & assigns ownership to deployer of this contract
    constructor() {
        _willExecutor = new WillExecutor();
        _willExecutor.transferOwnership(msg.sender);
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
        uint256[] memory _tokenIds,
        uint256[] memory _nftTokenURIs,
        string[] memory _nftTokenMetadata,
        address[] memory _nftRecipients
    ) public {
        require(
            wills[msg.sender].isConfirmed == false,
            "Will already exists and confirmed"
        );
        uint256[] memory _nftTokenIds = new uint256[](_nftTokenURIs.length);
        wills[msg.sender] = Will({
            isConfirmed: false,
            executors: _executors,
            tokenAmounts: _tokenAmounts,
            tokenAddresses: _tokenAddresses,
            tokenRecipients: _tokenRecipients,
            tokenIds: _tokenIds,
            nftTokenIds: _nftTokenIds,
            nftRecipients: _nftRecipients
        });

        // Mint NFTs and pre-approve their transfers
        for (uint256 i = 0; i < _nftTokenIds.length; i++) {
            willExecutor.mintNFT(msg.sender, _nftTokenMetadata[i]);
            willExecutor.preApproveNFTTransfer(
                _nftTokenIds[i],
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
}
