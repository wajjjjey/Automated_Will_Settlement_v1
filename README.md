# Automated_Will_Settlement_v1

Will Settlement Protocol
Will Settlement Protocol is a decentralized Ethereum-based application that enables any prospective testator to create and manage digital wills on the blockchain. The protocol allows users to securely distribute their digital assets (including ERC20 tokens and ERC721 non-fungible tokens) to designated beneficiaries upon their passing. The transfers are executed only after a specified number of executors confirm the will execution.

Features
Create and manage digital wills on the blockchain.
Securely distribute ERC20 tokens and ERC721 NFTs to designated beneficiaries.
Require confirmation from multiple executors before executing a will.
Built on Ethereum, utilizing the security and transparency of the blockchain.

Prerequisites
Before you can run the Will Protocol, ensure that you have the following tools installed:

Node.js (version >= 12.0.0)
npm (version >= 6.0.0)
Hardhat

I have put together the skeleton of a front-end to interact with the protocol, but right now it can be deployed and tested locally.

Protocol Mechanics

Will Protocol will deploy to a blockchain and deploy a secondary contract 'WillExecutor' to the same blockchain, retaining ownership. Users can call the 'createWill' function in 'WillProtocol' to create a smart contract of their will & testament, which has a preapproved transfer to intended recipients. Users can also detail physical assets to be transferred, and the 'WillExecutor' contract will mint NFTs to represent the transfer of ownership of the property. These NFTs will also be preapproved for transfer. The will will remain on the blockchain until pre-determined 'executors' send a transaction signature to 'WillProtocol' to confirm the death of the original testator and carry out thet transfer of assets. At this point, the record of the will will be deleted.

function createWill - creates will based on user input, preapproves token transfers and calls the mintNFTs function in 'WillExecutor'

function executeWill - executes transfer of assets once enough signatures are received from executors
