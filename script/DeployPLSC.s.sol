// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "src/Polis.sol";

/// @title DeployGenesis
/// @notice Foundry deployment script for GenesisParticipationToken to Sepolia testnet.
contract DeployPolis is Script {
    function run() external {
        string memory contractURI = "";

        vm.startBroadcast();

        Polis cntrct = new Polis(contractURI);

        vm.stopBroadcast();

        console.log("GenesisParticipationToken deployed at:", address(cntrct));
    }
}
