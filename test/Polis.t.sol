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

    /// @notice Deploy a new Polis contract before each test.
    function setUp() public {
        polis = new Polis("ipfs://polis-contract.json");
    }

    /// @notice Tests creation of multiple Polises and their unity assignments.
    function testCreatePolisAndGetUnity() public {
        polis.createNewPolis(5);
        polis.createNewPolis(10);

        assertEq(polis.getParentUnity(0), 5);
        assertEq(polis.getParentUnity(1), 10);
    }

    /// @notice Tests updating the parent Unity of a Polis and handling invalid IDs.
    function testSetParentUnity() public {
        polis.createNewPolis(3);
        polis.setParentUnity(0, 9);

        vm.expectRevert("Invalid _polisId.");
        polis.setParentUnity(99, 0);

        assertEq(polis.getParentUnity(0), 9);
    }

    /// @notice Reverts when attempting to get parent unity for nonexistent Polis.
    function test_Revert_SetParentUnity_InvalidPolisId() public {
        polis.createNewPolis(1);

        vm.expectRevert("Invalid _polisId.");
        polis.getParentUnity(99);
    }

    /// @notice Emits NewPolisCreated event upon Polis creation.
    function testEmit_NewPolisEvent() public {
        vm.expectEmit(true, false, false, false);
        emit NewPolisCreated(0, 1);
        polis.createNewPolis(1);
    }

    /// @notice Emits ParentUnityChanging event on unity update.
    function testEmit_ParentUnityChangingEvent() public {
        polis.createNewPolis(2);

        vm.expectEmit(true, false, false, false);
        emit ParentUnityChanging(0, 2, 4);
        polis.setParentUnity(0, 4);
    }

    /// @notice Reverts if a non-owner tries to change Polis unity.
    function test_Revert_When_NonOwnerSetsParentUnity() public {
        polis.createNewPolis(1);

        vm.prank(user);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user));
        polis.setParentUnity(0, 42);
    }

    /// @notice Tests filtered retrieval of Oikos tokens linked to a Polis.
    function testOikosListFiltering() public {
        polis.createNewPolis(1);
        polis.createNewPolis(2);

        polis.createNewOikosToken(user, "ipfs://a.json", 1, 1);
        polis.createNewOikosToken(user, "ipfs://b.json", 1, 2);
        polis.createNewOikosToken(user, "ipfs://c.json", 1, 3);
        polis.createNewOikosToken(user, "ipfs://d.json", 0, 3);

        uint256[] memory result = polis.getOikosList(1, 10, 2, 3);

        assertEq(result[0], 1);
        assertEq(result[1], 2);

        for (uint256 i = 2; i < result.length; i++) {
            assertEq(result[i], 0);
        }
    }

    /// @notice Reverts on invalid Polis ID in Oikos list query.
    function test_Revert_When_GetOikosList_InvalidPolisId() public {
        vm.expectRevert("Invalid _polisId.");
        polis.getOikosList(99, 10, 2, 3);
    }

    /// @notice Verifies empty result if no Oikos match filter.
    function testGetOikosListEmpty() public {
        polis.createNewPolis(1);
        polis.createNewPolis(2);
        polis.createNewOikosToken(user, "ipfs://nope.json", 0, 1);

        uint256[] memory result = polis.getOikosList(0, 5, 3, 4);
        for (uint256 i = 0; i < result.length; i++) {
            assertEq(result[i], 0);
        }
    }

    /// @notice Handles when more Oikos requested than available.
    function testGetOikosListUnderflow() public {
        polis.createNewPolis(1);
        polis.createNewOikosToken(user, "ipfs://1.json", 0, 3);

        uint256[] memory result = polis.getOikosList(0, 5, 3, 3);
        assertEq(result[0], 0);

        for (uint256 i = 1; i < result.length; i++) {
            assertEq(result[i], 0);
        }
    }

    /// @notice Reverts when status range is reversed.
    function test_Revert_When_InvalidStatusRange_MinGreaterThanMax() public {
        polis.createNewPolis(1);
        polis.createNewOikosToken(user, "ipfs://invalid.json", 0, 2);

        vm.expectRevert("Invalid _minStatus, _maxStatus.");
        polis.getOikosList(0, 10, 3, 2);
    }

    /// @notice Reverts when max status exceeds valid range.
    function test_Revert_When_InvalidStatusRange_MaxTooHigh() public {
        polis.createNewPolis(1);
        polis.createNewOikosToken(user, "ipfs://invalid.json", 0, 2);

        vm.expectRevert("Invalid _minStatus, _maxStatus.");
        polis.getOikosList(0, 10, 2, 99);
    }

    /// @notice Tests contract URI storage and updates.
    function testContractURIUpdate() public {
        assertEq(polis.contractURI(), "ipfs://polis-contract.json");

        polis.setContractURI("ipfs://updated-polis.json");
        assertEq(polis.contractURI(), "ipfs://updated-polis.json");
    }

    /// @notice Reverts if a non-owner tries to update contract URI.
    function test_Revert_When_NonOwnerChangesContractURI() public {
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user));
        polis.setContractURI("ipfs://unauthorized.json");
    }

    /// @notice Emits event on contract URI update.
    function testEmit_ContractURIUpdatedEvent() public {
        vm.expectEmit(false, false, false, true);
        emit ContractURIUpdated("ipfs://final-uri.json");
        polis.setContractURI("ipfs://final-uri.json");
    }

    /// @notice Tests multiple parent unity changes.
    function testOverwritingParentUnity() public {
        polis.createNewPolis(1);
        polis.setParentUnity(0, 2);
        polis.setParentUnity(0, 3);

        assertEq(polis.getParentUnity(0), 3);
    }

    /// @notice Tests basic flow of minting an Oikos token.
    function testCreateNewOikosToken_WorksAsExpected() public {
        polis.createNewPolis(1);

        polis.createNewOikosToken(user, "ipfs://test.json", 0, 3);

        assertEq(polis.ownerOf(0), user);
        assertEq(polis.getOikosStatus(0), 3);
        assertEq(polis.getParentPolis(0), 0);
    }

    /// @notice Reverts if status is out of allowed range.
    function test_Revert_When_CreateOikos_InvalidStatus() public {
        vm.expectRevert("Can't create new Oikos. Invalid _status value.");
        polis.createNewOikosToken(user, "ipfs://fail.json", 0, 5);
    }

    /// @notice Reverts if token URI is empty.
    function test_Revert_When_CreateOikos_InvalidTokenURI() public {
        vm.expectRevert("Can't create new Oikos. Invalid _tokenURI value.");
        polis.createNewOikosToken(user, "", 0, 1);
    }

    /// @notice Reverts if parent Polis does not exist.
    function test_Revert_When_CreateOikos_InvalidParentPolisId() public {
        vm.expectRevert("Can't create new Oikos. Invalid _parentPolisId value.");
        polis.createNewOikosToken(user, "ipfs://fail.json", 0, 2);
    }

    /// @notice Reverts if a non-owner attempts to mint Oikos.
    function test_Revert_When_NonOwnerMintsOikos() public {
        polis.createNewPolis(1);

        vm.prank(user);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user));
        polis.createNewOikosToken(user, "ipfs://hack.json", 0, 3);
    }
}