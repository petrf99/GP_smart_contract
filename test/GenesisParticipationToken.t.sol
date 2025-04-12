// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/GenesisParticipationToken.sol";

contract GenesisTest is Test {
    GenesisParticipationToken token;
    address owner;
    address user;

    function setUp() public {
        owner = address(this); // msg.sender
        user = address(0xBEEF);
        token = new GenesisParticipationToken("ipfs://base/", "ipfs://contract.json");
    }

    function testOwnerCanMint() public {
        token.createNewGPPT(user, "INV-001");
        assertEq(token.ownerOf(0), user);
        assertEq(token.getPartyNum(0), "INV-001");
    }

    function test_Revert_When_MintWithEmptyPartyNumber() public {
        vm.expectRevert("Party number must not be empty");
        token.createNewGPPT(user, "");
    }


    function testSetBaseURIBeforeMinting() public {
        token.setBaseURI("ipfs://newbase/");
        // изменений в блокчейне нет — просто проверяем, что не упало
    }

    function test_Revert_When_SetBaseURI_AfterMinting() public {
        token.createNewGPPT(user, "INV-002");

        vm.expectRevert("Too late to change baseURI, tokens have been minted.");
        token.setBaseURI("ipfs://too-late/");
    }


    function testContractURIChange() public {
        token.setContractURI("ipfs://new-contract.json");
        assertEq(token.contractURI(), "ipfs://new-contract.json");
    }
}