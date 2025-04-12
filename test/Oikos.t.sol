// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Oikos.sol";

contract OikosTest is Test {
    Oikos oikos;
    address user1 = address(0x1);
    address user2 = address(0x2);

    function setUp() public {
        oikos = new Oikos("ipfs://contract.json");
    }

    function testMintAndReadStatus() public {
        oikos.createNewOikosToken(user1, "ipfs://token1.json", 101, 3);

        assertEq(oikos.ownerOf(0), user1);
        assertEq(oikos.getParentPolis(0), 101);
        assertEq(oikos.getOikosStatus(0), 3);
    }

    function test_Revert_When_MintWithInvalidStatus() public {
        vm.expectRevert(); // нет кастомного revert-сообщения
        oikos.createNewOikosToken(user1, "ipfs://fail.json", 999, 0);
    }


    function testChangeTokenURI() public {
        oikos.createNewOikosToken(user1, "ipfs://old.json", 42, 2);
        oikos.changeOikosTokenURI(0, "ipfs://new.json");
        assertEq(oikos.tokenURI(0), "ipfs://new.json");
    }

    function testSetStatus() public {
        oikos.createNewOikosToken(user1, "ipfs://a.json", 1, 1);
        oikos.setOikosStatus(0, 2);
        assertEq(oikos.getOikosStatus(0), 2);
    }

    function testRemintingFlow() public {
        oikos.createNewOikosToken(user1, "ipfs://data.json", 55, 3);

        // действующий владелец разрешает реминт
        vm.prank(user1);
        oikos.setRemintingPermission(0, true);

        // контрак владелец запускает реминт
        oikos.remintOikosToken(0, user2);

        // старый токен деактивирован
        assertEq(oikos.getOikosStatus(0), 0);

        // новый токен выдан
        assertEq(oikos.ownerOf(1), user2);
        assertEq(oikos.getOikosStatus(1), 3);
        assertEq(oikos.getParentPolis(1), 55);
    }

    function test_Revert_When_RemintWithoutPermission() public {
        oikos.createNewOikosToken(user1, "ipfs://fail.json", 123, 1);
        vm.expectRevert("No permission to remint");
        oikos.remintOikosToken(0, user2);
    }

}