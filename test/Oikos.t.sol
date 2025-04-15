// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/Oikos.sol";

/// @title OikosToken Unit Tests
/// @notice Test suite for Oikos contract after removing contractURI logic.
/// @dev Uses TestableOikos to expose internal minting logic for testing.
contract OikosTest is Test {
    Oikos oikos;
    address user1 = address(0x1);
    address user2 = address(0x2);

    // Events for matching against emitted logs
    event OikosStatusChanging(uint256 oikosId, uint8 oldStatus, uint8 newStatus);
    event OikosTokenReminting(uint256 oikosId, address oldOwnerAddress, address newOwnerAddress);

    /// @notice Initializes a fresh instance of the contract before each test.
    function setUp() public {
        oikos = new Oikos();
    }

    /// @notice Tests minting a token and reading its metadata and associations.
    function testMintAndReadStatus() public {
        TestableOikos testable = new TestableOikos();
        testable.mint(user1, "ipfs://token1.json", 101, 3);

        assertEq(testable.ownerOf(0), user1);
        assertEq(testable.getParentPolis(0), 101);
        assertEq(testable.getOikosStatus(0), 3);

        vm.expectRevert("Invalid _oikosId.");
        testable.getOikosStatus(99);
    }

    /// @notice Test revert on getParentPolis for nonexisting token.
    function test_Revert_getParentPolis() public {
        TestableOikos testable = new TestableOikos();

        vm.expectRevert("Invalid _oikosId.");
        testable.getParentPolis(99);
    }

    /// @notice Tests that status updates work and emit the correct event.
    function testSetStatusWithEvent() public {
        TestableOikos testable = new TestableOikos();
        testable.mint(user1, "ipfs://a.json", 1, 1);

        vm.expectRevert("Invalid _oikosId.");
        testable.setOikosStatus(99, 2);

        vm.expectEmit(true, false, false, true);
        emit OikosStatusChanging(0, 1, 2);

        testable.setOikosStatus(0, 2);
        assertEq(testable.getOikosStatus(0), 2);
    }

    /// @notice Tests that onlyOwner restriction applies to status updates.
    function test_Revert_When_NonOwnerSetsStatus() public {
        TestableOikos testable = new TestableOikos();
        testable.mint(user1, "ipfs://b.json", 1, 1);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user1));
        testable.setOikosStatus(0, 3);
    }

    /// @notice Tests updating the number of valid statuses.
    function testStatusNumChangeAllowsNewStatus() public {
        TestableOikos testable = new TestableOikos();
        testable.setStatusNum(10);
        testable.mint(user1, "ipfs://c.json", 7, 10);
        assertEq(testable.getOikosStatus(0), 10);
    }

    /// @notice Tests reminting flow and associated event emission.
    function testRemintingFlowWithEvent() public {
        TestableOikos testable = new TestableOikos();
        testable.mint(user1, "ipfs://data.json", 55, 3);

        vm.prank(user1);
        testable.setRemintingPermission(0, true);

        vm.expectEmit(true, true, false, false);
        emit OikosTokenReminting(0, user1, user2);

        testable.remintOikosToken(0, user2);

        assertEq(testable.getOikosStatus(0), 0); // Old token deactivated
        assertEq(testable.ownerOf(1), user2); // New token minted
        assertEq(testable.getOikosStatus(1), 3);
        assertEq(testable.getParentPolis(1), 55);
    }

    /// @notice Tests remint fails without permission.
    function test_Revert_When_RemintWithoutPermission() public {
        TestableOikos testable = new TestableOikos();
        testable.mint(user1, "ipfs://fail.json", 123, 1);

        vm.expectRevert("No permission to remint.");
        testable.remintOikosToken(0, user2);

        vm.expectRevert("Invalid _oikosId.");
        testable.remintOikosToken(99, user1);
    }

    /// @notice Tests overwriting remint permission and ensuring enforcement.
    function testRemintingPermissionOverwrite() public {
        TestableOikos testable = new TestableOikos();
        testable.mint(user1, "ipfs://1.json", 1, 2);

        vm.prank(user1);
        testable.setRemintingPermission(0, true);

        vm.prank(user1);
        testable.setRemintingPermission(0, false);

        vm.expectRevert("No permission to remint.");
        testable.remintOikosToken(0, user2);

        vm.expectRevert("Invalid _oikosId.");
        testable.setRemintingPermission(99, false);
    }

    /// @notice Tests changeOikosTokenURI reverts.
    function test_Revert_changeOikosTokenURI() public  {
        TestableOikos testable = new TestableOikos();

        vm.expectRevert("Invalid _oikosId.");
        testable.changeOikosTokenURI(99, "ipfs://abc/turi.json");

        testable.mint(user1, "ipfs://1.json", 1, 2);

        vm.expectRevert("Invalid _tokenURI value.");
        testable.changeOikosTokenURI(0, "");
    }
}

/// @dev Helper contract to expose internal `mintNewOikosToken()` for testing.
contract TestableOikos is Oikos {
    constructor() Oikos() {}

    function mint(address to, string memory uri, uint16 polisId, uint8 status) public onlyOwner {
        mintNewOikosToken(to, uri, polisId, status);
    }
}
