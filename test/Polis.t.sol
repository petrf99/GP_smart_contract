// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Polis.sol";

/// @title Polis Contract Unit Tests
/// @notice Full test suite for the Polis contract and its extended logic over Oikos.
/// @dev Covers Polis creation, hierarchy, Oikos minting, filtering, metadata, and access control.
contract PolisTest is Test {
    Polis polis;
    address user = address(0xBEEF);

    event NewPolisCreated(uint16 polisId, uint8 parentUnityId);
    event ParentUnityChanging(uint16 polisId, uint8 oldParentUnityId, uint8 newParentUnityId);
    event ContractURIUpdated(string newContractURI);

    function setUp() public {
        polis = new Polis("ipfs://polis-contract.json");
    }

    /// @notice Tests creation of multiple Polises and retrieval of their unity IDs.
    function testCreatePolisAndGetUnity() public {
        polis.createNewPolis(5);
        polis.createNewPolis(10);

        assertEq(polis.getParentUnity(0), 5);
        assertEq(polis.getParentUnity(1), 10);
    }

    /// @notice Tests updating a Polis’s parent Unity.
    function testSetParentUnity() public {
        polis.createNewPolis(3);
        polis.setParentUnity(0, 9);

        assertEq(polis.getParentUnity(0), 9);
    }

    /// @notice Tests emitting of NewPolisCreated event.
    function testEmit_NewPolisEvent() public {
        vm.expectEmit(true, false, false, false);
        emit NewPolisCreated(0, 1);
        polis.createNewPolis(1);
    }

    /// @notice Tests emitting of ParentUnityChanging event.
    function testEmit_ParentUnityChangingEvent() public {
        polis.createNewPolis(2);

        vm.expectEmit(true, false, false, false);
        emit ParentUnityChanging(0, 2, 4);
        polis.setParentUnity(0, 4);
    }

    /// @notice Ensures only owner can update parent unity.
    function test_Revert_When_NonOwnerSetsParentUnity() public {
        polis.createNewPolis(1);

        vm.prank(user);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user));
        polis.setParentUnity(0, 42);
    }

    /// @notice Tests correct filtering of Oikos tokens by status and parent Polis.
    function testOikosListFiltering() public {
        polis.createNewPolis(1);
        polis.createNewPolis(2);

        polis.createNewOikosToken(user, "ipfs://a.json", 1, 1);
        polis.createNewOikosToken(user, "ipfs://b.json", 1, 2);
        polis.createNewOikosToken(user, "ipfs://c.json", 1, 3);
        polis.createNewOikosToken(user, "ipfs://d.json", 2, 3);

        uint256[] memory result = polis.getOikosList(1, 10, 2, 3);

        assertEq(result[0], 1); // status 2
        assertEq(result[1], 2); // status 3

        for (uint256 i = 2; i < result.length; i++) {
            assertEq(result[i], 0); // remainder
        }
    }

    /// @notice Checks output of getOikosList with no matches.
    function testGetOikosListEmpty() public {
        polis.createNewPolis(1);
        polis.createNewPolis(2);
        polis.createNewOikosToken(user, "ipfs://nope.json", 2, 1); // wrong Polis

        uint256[] memory result = polis.getOikosList(1, 5, 3, 4);
        for (uint256 i = 0; i < result.length; i++) {
            assertEq(result[i], 0);
        }
    }

    /// @notice Tests when requested list length exceeds available tokens.
    function testGetOikosListUnderflow() public {
        polis.createNewPolis(1);
        polis.createNewOikosToken(user, "ipfs://1.json", 1, 3);

        uint256[] memory result = polis.getOikosList(1, 5, 3, 3);
        assertEq(result[0], 0);

        for (uint256 i = 1; i < result.length; i++) {
            assertEq(result[i], 0);
        }
    }

    /// @notice Tests invalid status range (min > max) returns empty list.
    function testGetOikosListInvalidStatusRange() public {
        polis.createNewPolis(1);
        polis.createNewOikosToken(user, "ipfs://invalid.json", 1, 2);

        uint256[] memory result = polis.getOikosList(1, 5, 4, 1);
        for (uint256 i = 0; i < result.length; i++) {
            assertEq(result[i], 0);
        }
    }

    /// @notice Verifies that contract URI is initialized correctly and updatable.
    function testContractURIUpdate() public {
        assertEq(polis.contractURI(), "ipfs://polis-contract.json");

        polis.setContractURI("ipfs://updated-polis.json");
        assertEq(polis.contractURI(), "ipfs://updated-polis.json");
    }

    /// @notice Checks access control for contract URI update.
    function test_Revert_When_NonOwnerChangesContractURI() public {
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user));
        polis.setContractURI("ipfs://unauthorized.json");
    }

    /// @notice Ensures ContractURIUpdated event is emitted correctly.
    function testEmit_ContractURIUpdatedEvent() public {
        vm.expectEmit(false, false, false, true);
        emit ContractURIUpdated("ipfs://final-uri.json");
        polis.setContractURI("ipfs://final-uri.json");
    }

    /// @notice Tests update of allowed status values through inherited setter.
    function testStatusNumUpdateAndMint() public {
        polis.setStatusNum(8);
        polis.createNewPolis(1);
        polis.createNewOikosToken(user, "ipfs://status8.json", 1, 8);

        assertEq(polis.getOikosStatus(0), 8);
    }

    /// @notice Tests overwriting parent Unity multiple times.
    function testOverwritingParentUnity() public {
        polis.createNewPolis(1);
        polis.setParentUnity(0, 2);
        polis.setParentUnity(0, 3);

        assertEq(polis.getParentUnity(0), 3);
    }

    /// @notice Tests createNewOikosToken functionality.
    function testCreateNewOikosToken_WorksAsExpected() public {
        polis.createNewPolis(1); // Required to satisfy require(nextPolisId > 0)

        polis.createNewOikosToken(user, "ipfs://test.json", 0, 3);

        assertEq(polis.ownerOf(0), user);
        assertEq(polis.getOikosStatus(0), 3);
        assertEq(polis.getParentPolis(0), 0);
    }

    /// @notice Ensures createNewOikosToken fails if no Polis exists.
    function test_Revert_When_CreateOikos_WithoutPolis() public {
        vm.expectRevert(); // nextPolisId == 0
        polis.createNewOikosToken(user, "ipfs://fail.json", 0, 2);
    }

    /// @notice Ensures onlyOwner can mint new Oikos tokens.
    function test_Revert_When_NonOwnerMintsOikos() public {
        polis.createNewPolis(1);

        vm.prank(user);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user));
        polis.createNewOikosToken(user, "ipfs://hack.json", 0, 3);
    }
}
