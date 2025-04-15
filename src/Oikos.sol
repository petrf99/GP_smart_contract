// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Oikos Token
/// @notice ERC721 token representing a digital private property unit in a Polis.
/// @dev Inherits from OpenZeppelin's ERC721URIStorage and Ownable contracts.
contract Oikos is ERC721URIStorage, Ownable {
    event OikosStatusChanging(uint256 oikosId, uint8 oldStatus, uint8 newStatus);
    event OikosTokenReminting(uint256 oikosId, address oldOwnerAddress, address newOwnerAddress);

    uint256 nextOikosId;

    /// Map to Polis in which Oikos resides.
    mapping(uint256 => uint16) oikosToPolis;

    /// Statuses: 0 - token deactivated, 1 - in property, 2 - is being used, 3 - on sale, 4 - in project.
    uint8 statusNum = 4;
    mapping(uint256 => uint8) oikosToStatus;

    /// Permissions on reminting of tokens.
    mapping(uint256 => bool) private _remintingPermissions;

    /// @notice Sets token name and contract owner.
    constructor() ERC721("OikosToken", "OKST") Ownable(msg.sender) {
        //
    }

    /// @notice Create new Oikos Token.
    /// @param _to Address of the owner.
    /// @param _tokenURI Token metadata URI.
    /// @param _parentPolisId Polis in which Oikos resides.
    /// @param _status Oikos status: 0 - token deactivated, 1 - in property, 2 - is being used, 3 - on sale, 4 - in project.
    function mintNewOikosToken(address _to, string memory _tokenURI, uint16 _parentPolisId, uint8 _status) internal {
        _safeMint(_to, nextOikosId);
        oikosToStatus[nextOikosId] = _status;
        oikosToPolis[nextOikosId] = _parentPolisId;
        _setTokenURI(nextOikosId, _tokenURI);
        nextOikosId++;
    }

    /// @notice Change of Oikos Token URI.
    /// @param _oikosId Id of the Oikos Token.
    /// @param _tokenURI New metadata URI.
    /// @dev onlyOwner.
    function changeOikosTokenURI(uint256 _oikosId, string memory _tokenURI) public onlyOwner {
        require(_oikosId < nextOikosId, "Invalid _oikosId.");
        require(bytes(_tokenURI).length > 0, "Invalid _tokenURI value.");
        _setTokenURI(_oikosId, _tokenURI);
    }

    /// @notice Get Polis in which Oikos resides.
    /// @param _oikosId Id of the Oikos Token.
    /// @return Id of Polis.
    function getParentPolis(uint256 _oikosId) public view returns (uint16) {
        require(_oikosId < nextOikosId, "Invalid _oikosId.");
        return oikosToPolis[_oikosId];
    }

    /// @notice Returns the status of the Oikos token.
    /// @param _oikosId Id of the Oikos Token.
    /// @return uint8 Status code.
    function getOikosStatus(uint256 _oikosId) public view returns (uint8) {
        require(_oikosId < nextOikosId, "Invalid _oikosId.");
        return oikosToStatus[_oikosId];
    }

    /// @notice Set new Oikos Status.
    /// @param _oikosId Id of the Oikos Token.
    /// @param _newStatus New Status.
    /// @dev onlyOwner.
    function setOikosStatus(uint256 _oikosId, uint8 _newStatus) public onlyOwner {
        require(_oikosId < nextOikosId, "Invalid _oikosId.");
        require(oikosToStatus[_oikosId] > 0 && _newStatus <= statusNum, "Invalid _newStatus value.");
        emit OikosStatusChanging(_oikosId, oikosToStatus[_oikosId], _newStatus);
        oikosToStatus[_oikosId] = _newStatus;
    }

    /// @notice Set number of different statuses.
    /// @param _newStatusNum New number of statuses.
    /// @dev onlyOwner.
    function setStatusNum(uint8 _newStatusNum) public onlyOwner {
        statusNum = _newStatusNum;
    }

    /// @notice Grants or revokes permission to remint the token.
    /// @param _oikosId Id of the Oikos Token.
    /// @param _perm New bool value of permission (true/false)
    /// @dev Available only to the owner of token.
    function setRemintingPermission(uint256 _oikosId, bool _perm) public {
        require(_oikosId < nextOikosId, "Invalid _oikosId.");
        require(msg.sender == ownerOf(_oikosId), "Only available for the owner of the token.");
        /// only owner of oikos can change permissions
        _remintingPermissions[_oikosId] = _perm;
    }

    /// @notice Remint (disactivate old and create new) token in case if owner lost access to his account (private key). Can be run only by the owner of the contract.
    /// @param _oikosId Id of the Oikos Token.
    /// @param _newOwnerAddress New address of the same real-world owner.
    /// @dev onlyOwner.
    function remintOikosToken(uint256 _oikosId, address _newOwnerAddress) public onlyOwner {
        require(_oikosId < nextOikosId, "Invalid _oikosId.");
        require(_newOwnerAddress != address(0), "Invalid _newOwnerAddress value.");
        require(oikosToStatus[_oikosId] != 0, "Token is deactivated.");
        require(_remintingPermissions[_oikosId] == true, "No permission to remint.");
        uint8 act_status = oikosToStatus[_oikosId];
        emit OikosTokenReminting(_oikosId, ownerOf(_oikosId), _newOwnerAddress);
        oikosToStatus[_oikosId] = 0; // deactivate token
        mintNewOikosToken(_newOwnerAddress, tokenURI(_oikosId), oikosToPolis[_oikosId], act_status);
    }
}
