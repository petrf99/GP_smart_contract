// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/GenesisParticipationToken.sol";

/// @title GenesisParticipationToken Unit Tests
/// @notice Complete test suite for the GenesisParticipationToken smart contract.
/// @dev Covers minting, metadata, event emission, access control, and error conditions.
contract GenesisTest is Test {
    GenesisParticipationToken token;
    address owner;
    address user = address(0xBEEF);

    /// @dev Local declaration of contract events for expectEmit.
    event TokenCreated(address indexed to, uint256 indexed tokenId, string partyNumber);
    event BaseURIUpdated(string newBaseURI);
    event ContractURIUpdated(string newContractURI);

    /// @notice Sets up the test environment with fresh contract instance.
    function setUp() public {
        token = new GenesisParticipationToken("ipfs://base/", "ipfs://contract.json");
    }

    /// @notice Tests that the owner can mint a token with valid data.
    /// @dev Checks owner assignment and party number association.
    function testOwnerCanMint() public {
        token.createNewGPPT(user, "INV-001");
        assertEq(token.ownerOf(0), user);
        assertEq(token.getPartyNum(0), "INV-001");
    }

    /// @notice Tests that the TokenCreated event is emitted on mint.
    function testEmit_TokenCreated() public {
        vm.expectEmit(true, true, false, true);
        emit TokenCreated(user, 0, "INV-002");
        token.createNewGPPT(user, "INV-002");
    }

    /// @notice Tests revert when trying to mint with empty party number.
    function test_Revert_When_MintWithEmptyPartyNumber() public {
        vm.expectRevert("Party number must not be empty");
        token.createNewGPPT(user, "");
    }

    /// @notice Tests that base URI can be changed before minting any tokens.
    function testSetBaseURIBeforeMinting() public {
        vm.expectEmit(false, false, false, true);
        emit BaseURIUpdated("ipfs://newbase/");
        token.setBaseURI("ipfs://newbase/");
    }

    /// @notice Tests revert when trying to change base URI after minting.
    function test_Revert_When_SetBaseURI_AfterMinting() public {
        token.createNewGPPT(user, "INV-002");
        vm.expectRevert("Too late to change baseURI, tokens have been minted.");
        token.setBaseURI("ipfs://too-late/");
    }

    /// @notice Tests that contract URI can be changed and emits event.
    function testContractURIChange() public {
        vm.expectEmit(false, false, false, true);
        emit ContractURIUpdated("ipfs://new-contract.json");
        token.setContractURI("ipfs://new-contract.json");
        assertEq(token.contractURI(), "ipfs://new-contract.json");
    }

    /// @notice Tests that only the contract owner can change base URI.
    function test_Revert_When_NonOwnerChangesBaseURI() public {
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user));
        token.setBaseURI("ipfs://malicious-change/");
    }

    /// @notice Tests that only the contract owner can change contract URI.
    function test_Revert_When_NonOwnerChangesContractURI() public {
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user));
        token.setContractURI("ipfs://hacker.json");
    }

    /// @notice Tests that getPartyNum fails if token does not exist.
    function test_Revert_When_GetPartyNumForNonexistentToken() public {
        vm.expectRevert("Token does not exist");
        token.getPartyNum(42);
    }

    /// @notice Tests internal _baseURI logic (view).
    function testBaseURIReturnsCorrectValue() public {
        // _baseURI is internal, but we can test it indirectly
        token.createNewGPPT(user, "TEST");
        string memory expectedURI = "ipfs://base/0.json";
        assertEq(token.tokenURI(0), expectedURI);
    }
}
