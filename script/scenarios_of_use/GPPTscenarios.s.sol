// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "src/GenesisParticipationToken.sol";
import "forge-std/console.sol";

/// @title MintGPPT
/// @notice Step 1. Mint some GenesisParticipationTokens. Should be run by the GPPT contract owner (Dev).
contract MintGPPTs is Script {
    using Strings for uint256;

    function run() external {
        address gpptAddress = vm.envAddress("GPPT_SEPOLIA_ADDRESS");
        GenesisParticipationToken token = GenesisParticipationToken(gpptAddress);

        address tokenOwner = vm.envAddress("PUBLIC_KEY_GD"); // GD - Genesis Development (system owner)
        uint256 numberOfTokens = 5;

        string memory partyNum = "TEST_PARTY_NUM-";
        string memory partyNumTemp;

        vm.startBroadcast();
        for (uint256 i = 0; i < numberOfTokens; i++) {
            partyNumTemp = string(abi.encodePacked(partyNum, i.toString()));
            token.createNewGPPT(tokenOwner, partyNumTemp);
            console.log("GPPT minted");
            console.logUint(i);
            console.log("Owner:");
            console.logAddress(tokenOwner);
        }
        vm.stopBroadcast();
    }
}

/// @title TransferGPPTs
/// @notice Step 2. Transfer some GPPTs to customers. Should be run by the owner of tokens (GD).
contract TransferGPPTs is Script {
    function run() external {
        address gpptAddress = vm.envAddress("GPPT_SEPOLIA_ADDRESS");
        GenesisParticipationToken token = GenesisParticipationToken(gpptAddress);

        address customer = vm.envAddress("PUBLIC_KEY_CUSTOMER");
        address owner = vm.envAddress("PUBLIC_KEY_GD");

        uint256 nTokensToTransfer = 3;
        uint256[] memory gpptsToTransfer = new uint256[](nTokensToTransfer);
        gpptsToTransfer[0] = 2;
        gpptsToTransfer[1] = 4;
        gpptsToTransfer[2] = 0;

        vm.startBroadcast();
        for (uint256 i = 0; i < nTokensToTransfer; i++) {
            token.transferFrom(owner, customer, gpptsToTransfer[i]);
            console.log("Transferred token");
            console.logUint(gpptsToTransfer[i]);
            console.log("from:");
            console.logAddress(owner);
            console.log("to:");
            console.logAddress(customer);
        }
        vm.stopBroadcast();
    }
}

/// @title CheckGPPTs
/// @notice Step 3. Customer checks his GPPTs. No broadcast here - anyone can run.
contract CheckGPPTs is Script {
    function run() external view {
        address gpptAddress = vm.envAddress("GPPT_SEPOLIA_ADDRESS");
        GenesisParticipationToken token = GenesisParticipationToken(gpptAddress);

        address customer = vm.envAddress("PUBLIC_KEY_CUSTOMER");

        uint256 nTokensToTransfer = 3;
        uint256[] memory gpptsToTransfer = new uint256[](nTokensToTransfer);
        gpptsToTransfer[0] = 2;
        gpptsToTransfer[1] = 4;
        gpptsToTransfer[2] = 0;

        for (uint256 i = 0; i < nTokensToTransfer; i++) {
            address realOwner = token.ownerOf(gpptsToTransfer[i]);
            console.log("Transferred token");
            console.logUint(gpptsToTransfer[i]);
            console.log("New owner:");
            console.logAddress(realOwner);
            console.log("Expected owner:");
            console.logAddress(customer);
            console.log("TokenURI");
            console.log(token.tokenURI(gpptsToTransfer[i]));
        }
    }
}
