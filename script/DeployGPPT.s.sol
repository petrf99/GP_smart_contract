// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "src/GenesisParticipationToken.sol";

/// @title DeployGenesis
/// @notice Foundry deployment script for GenesisParticipationToken to Sepolia testnet.
contract DeployGenesis is Script {
    function run() external {
        string memory baseURI = "ipfs://bafybeifray3lprk45rtvcsfzv3jw2kdsdtfdhnnww2mfweq665mliuofsu/";
        string memory contractURI = "ipfs://bafybeifray3lprk45rtvcsfzv3jw2kdsdtfdhnnww2mfweq665mliuofsu/GPPT_contract_metadata_test.json";


        vm.startBroadcast(); 

        GenesisParticipationToken token = new GenesisParticipationToken(baseURI, contractURI);

        vm.stopBroadcast(); 

        console.log("GenesisParticipationToken deployed at:", address(token));
    }
}