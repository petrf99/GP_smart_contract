// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Polis.sol";

/// @title Polis Contract Unit Tests
/// @notice Unit tests for the Polis contract and its extended logic over Oikos.
/// @dev Tests cover creation, hierarchy, filtering, metadata control, and access rights.
contract PolisTest is Test {
    /// @dev Local copies of events from Polis/Oikos contracts
    event NewPolis(uint16 polisId, uint8 parentUnityId);
    event ParentUnityChanging(uint16 polisId, uint8 oldParentUnityId, uint8 newParentUnityId);
    event ContractURIUpdated(string newContractURI);

    Polis polis;
    address user = address(0xBEEF);

    /// @notice Sets up a fresh Polis instance before each test.
    /// @dev Initializes the contract with a default metadata URI.
    function setUp() public {
        polis = new Polis("ipfs://polis-contract.json");
    }

    /// @notice Tests creation of multiple Polises and retrieval of their Unity values.
    /// @dev Verifies that each Polis correctly stores the assigned parent Unity ID.
    function testCreatePolisAndGetUnity() public {
        polis.createNewPolis(7);
        polis.createNewPolis(9);

        assertEq(polis.getParentUnity(0), 7);
        assertEq(polis.getParentUnity(1), 9);
    }

    /// @notice Tests updating the Unity of an existing Polis.
    /// @dev Verifies that the change is stored and can be read back.
    function testSetParentUnity() public {
        polis.createNewPolis(5);
        polis.setParentUnity(0, 99);

        assertEq(polis.getParentUnity(0), 99);
    }

    /// @notice Tests filtering of Oikos tokens within a given Polis by status range.
    /// @dev Creates tokens with varying statuses and verifies correct inclusion/exclusion in the result array.
    function testOikosListFiltering() public {
        polis.createNewPolis(1);
        polis.createNewPolis(2);

        // Add 3 tokens to Polis 1, and 1 token to Polis 2
        polis.createNewOikosToken(user, "ipfs://o1.json", 1, 3);
        polis.createNewOikosToken(user, "ipfs://o2.json", 1, 2);
        polis.createNewOikosToken(user, "ipfs://o3.json", 1, 1);
        polis.createNewOikosToken(user, "ipfs://o4.json", 2, 3);

        // Get list of tokens from Polis 1 with status between 2 and 3
        uint256[] memory result = polis.getOikosList(1, 10, 2, 3);

        assertEq(result[0], 0); // o1
        assertEq(result[1], 1); // o2

        // Remaining slots should be zeroed (unused array space)
        for (uint256 i = 2; i < result.length; i++) {
            assertEq(result[i], 0);
        }
    }

    /// @notice Tests that contract URI can be updated by the owner.
    /// @dev Verifies getter reflects the new value after update.
    function testContractURIChange() public {
        assertEq(polis.contractURI(), "ipfs://polis-contract.json");

        polis.setContractURI("ipfs://updated-polis.json");
        assertEq(polis.contractURI(), "ipfs://updated-polis.json");
    }

    /// @notice Tests that only the contract owner can update the contract URI.
    /// @dev Expects revert with OwnableUnauthorizedAccount when called by unauthorized user.
    function testContractURIAccessControl() public {
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user));
        polis.setContractURI("ipfs://should-fail.json");
    }

    /// @notice Tests that NewPolis event is emitted correctly.
    function testEmit_NewPolisEvent() public {
        vm.expectEmit(true, false, false, false);
        emit NewPolis(0, 7);
        polis.createNewPolis(7);
    }

    /// @notice Tests that ParentUnityChanging event is emitted on change.
    function testEmit_ParentUnityChangeEvent() public {
        polis.createNewPolis(1);

        vm.expectEmit(true, false, false, false);
        emit ParentUnityChanging(0, 1, 42);
        polis.setParentUnity(0, 42);
    }

    /// @notice Tests that ContractURIUpdated event is emitted on change.
    function testEmit_ContractURIUpdatedEvent() public {
        vm.expectEmit(false, false, false, true);
        emit ContractURIUpdated("ipfs://new.json");
        polis.setContractURI("ipfs://new.json");
    }

    /// @notice Tests access control for setParentUnity (onlyOwner).
    function test_Revert_When_NonOwnerSetsParentUnity() public {
        polis.createNewPolis(1);
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user));
        polis.setParentUnity(0, 88);
    }

    /// @notice Tests getOikosList when there are no matching Oikos tokens.
    function testGetOikosListEmptyResult() public {
        polis.createNewPolis(1);
        polis.createNewPolis(2);
        polis.createNewOikosToken(user, "ipfs://nope.json", 2, 1); // Wrong Polis

        uint256[] memory result = polis.getOikosList(1, 5, 3, 4);
        for (uint256 i = 0; i < result.length; i++) {
            assertEq(result[i], 0); // no matches
        }
    }

    /// @notice Tests getOikosList when requested number exceeds actual matches.
    function testGetOikosListLimitExceedsMatches() public {
        polis.createNewPolis(1);
        polis.createNewOikosToken(user, "ipfs://a.json", 1, 3);
        uint256[] memory result = polis.getOikosList(1, 5, 3, 3);

        assertEq(result[0], 0);
        for (uint256 i = 1; i < result.length; i++) {
            assertEq(result[i], 0);
        }
    }

    /// @notice Tests getOikosList with invalid status range (min > max).
    function testGetOikosListInvalidStatusRange() public {
        polis.createNewPolis(1);
        polis.createNewOikosToken(user, "ipfs://x.json", 1, 2);
        uint256[] memory result = polis.getOikosList(1, 10, 4, 2);

        for (uint256 i = 0; i < result.length; i++) {
            assertEq(result[i], 0); // no result expected
        }
    }

    /// @notice Tests that statusNum can be updated by owner.
    function testStatusNumUpdate() public {
        // Directly calling public setter to change allowed statuses
        polis.setStatusNum(10);
        // Minting with new status should now be allowed
        polis.createNewOikosToken(user, "ipfs://x.json", 1, 8);
        assertEq(polis.getOikosStatus(0), 8);
    }

    /// @notice Tests overwriting parent unity of a Polis multiple times.
    function testParentUnityOverwrites() public {
        polis.createNewPolis(1);
        polis.setParentUnity(0, 2);
        polis.setParentUnity(0, 3);

        assertEq(polis.getParentUnity(0), 3);
    }
}
