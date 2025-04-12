
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Polis.sol";

contract PolisTest is Test {
    Polis polis;
    address user = address(0xBEEF);

    function setUp() public {
        polis = new Polis("ipfs://polis-contract.json");
    }

    function testCreatePolisAndGetUnity() public {
        polis.createNewPolis(7);
        polis.createNewPolis(9);

        assertEq(polis.getParentUnity(0), 7);
        assertEq(polis.getParentUnity(1), 9);
    }

    function testSetParentUnity() public {
        polis.createNewPolis(5);
        polis.setParentUnity(0, 99);
        assertEq(polis.getParentUnity(0), 99);
    }

    function testOikosListFiltering() public {
        polis.createNewPolis(1);
        polis.createNewPolis(2);

        polis.createNewOikosToken(user, "ipfs://o1.json", 1, 3);
        polis.createNewOikosToken(user, "ipfs://o2.json", 1, 2);
        polis.createNewOikosToken(user, "ipfs://o3.json", 1, 1);
        polis.createNewOikosToken(user, "ipfs://o4.json", 2, 3);

        uint256[] memory result = polis.getOikosList(1, 10, 2, 3);

        // Мы ожидаем, что первые 2 элемента будут не нулями
        assertEq(result[0], 0);
        assertEq(result[1], 1);

        // А остальные — нули (потому что не заполнились)
        for (uint256 i = 2; i < result.length; i++) {
            assertEq(result[i], 0);
        }
    }


    function testContractURIChange() public {
        assertEq(polis.contractURI(), "ipfs://polis-contract.json");

        polis.setContractURI("ipfs://updated-polis.json");
        assertEq(polis.contractURI(), "ipfs://updated-polis.json");
    }

    function testContractURIAccessControl() public {
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user));
        polis.setContractURI("ipfs://should-fail.json");
    }


}