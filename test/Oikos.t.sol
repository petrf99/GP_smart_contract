// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Oikos.sol";

/// @title OikosToken Unit Tests
/// @notice Full test suite for the Oikos contract.
/// @dev Covers minting, URI, status, reminting, permissions, events, access control, and config.
contract OikosTest is Test {
    Oikos oikos;
    address user1 = address(0x1);
    address user2 = address(0x2);

    /// @dev Local declarations of events (for vm.expectEmit)
    event OikosStatusChanging(uint256 oikosId, uint8 oldStatus, uint8 newStatus);
    event OikosTokenReminting(uint256 oikosId, address oldOwnerAddress, address newOwnerAddress);
    event ContractURIUpdated(string newContractURI);

    /// @notice Initializes fresh contract before each test.
    function setUp() public {
        oikos = new Oikos("ipfs://contract.json");
    }

    /// @notice Tests minting a new token and reading its properties.
    function testMintAndReadStatus() public {
        oikos.createNewOikosToken(user1, "ipfs://token1.json", 101, 3);

        assertEq(oikos.ownerOf(0), user1);
        assertEq(oikos.getParentPolis(0), 101);
        assertEq(oikos.getOikosStatus(0), 3);
    }

    /// @notice Tests that minting with invalid status is rejected.
    function test_Revert_When_MintWithInvalidStatus() public {
        vm.expectRevert();
        oikos.createNewOikosToken(user1, "ipfs://fail.json", 999, 0);
    }

    /// @notice Tests updating token URI as owner.
    function testChangeTokenURI() public {
        oikos.createNewOikosToken(user1, "ipfs://old.json", 42, 2);
        oikos.changeOikosTokenURI(0, "ipfs://new.json");

        assertEq(oikos.tokenURI(0), "ipfs://new.json");
    }

    /// @notice Tests status update and emits event.
    function testSetStatusWithEvent() public {
        oikos.createNewOikosToken(user1, "ipfs://a.json", 1, 1);

        vm.expectEmit(true, false, false, true);
        emit OikosStatusChanging(0, 1, 2);
        oikos.setOikosStatus(0, 2);
        assertEq(oikos.getOikosStatus(0), 2);
    }

    /// @notice Tests status update rejection for non-owner.
    function test_Revert_When_NonOwnerSetsStatus() public {
        oikos.createNewOikosToken(user1, "ipfs://b.json", 1, 1);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user1));
        oikos.setOikosStatus(0, 3);
    }

    /// @notice Tests updating the max allowed statusNum and using it.
    function testStatusNumChangeAllowsNewStatus() public {
        oikos.setStatusNum(10);
        oikos.createNewOikosToken(user1, "ipfs://c.json", 7, 10);
        assertEq(oikos.getOikosStatus(0), 10);
    }

    /// @notice Tests full reminting flow and event emission.
    function testRemintingFlowWithEvent() public {
        oikos.createNewOikosToken(user1, "ipfs://data.json", 55, 3);

        vm.prank(user1);
        oikos.setRemintingPermission(0, true);

        vm.expectEmit(true, true, false, false);
        emit OikosTokenReminting(0, user1, user2);

        oikos.remintOikosToken(0, user2);

        assertEq(oikos.getOikosStatus(0), 0);
        assertEq(oikos.ownerOf(1), user2);
        assertEq(oikos.getOikosStatus(1), 3);
        assertEq(oikos.getParentPolis(1), 55);
    }

    /// @notice Tests that reminting fails without granted permission.
    function test_Revert_When_RemintWithoutPermission() public {
        oikos.createNewOikosToken(user1, "ipfs://fail.json", 123, 1);
        vm.expectRevert("No permission to remint");
        oikos.remintOikosToken(0, user2);
    }

    /// @notice Tests repeated permission setting by owner.
    function testRemintingPermissionOverwrite() public {
        oikos.createNewOikosToken(user1, "ipfs://1.json", 1, 2);

        vm.prank(user1);
        oikos.setRemintingPermission(0, true);

        vm.prank(user1);
        oikos.setRemintingPermission(0, false);

        vm.expectRevert("No permission to remint");
        oikos.remintOikosToken(0, user2);
    }

    /// @notice Tests contractURI update and event emission.
    function testContractURIUpdate() public {
        vm.expectEmit(false, false, false, true);
        emit ContractURIUpdated("ipfs://new-contract-uri.json");

        oikos.setContractURI("ipfs://new-contract-uri.json");
        assertEq(oikos.contractURI(), "ipfs://new-contract-uri.json");
    }

    /// @notice Tests onlyOwner access control for contractURI change.
    function test_Revert_When_NonOwnerChangesContractURI() public {
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user1));
        oikos.setContractURI("ipfs://unauthorized.json");
    }
}
