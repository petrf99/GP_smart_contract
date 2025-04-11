// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Oikos is ERC721, ERC721URIStorage,  Ownable {

    event OikosStatusChanging(uint256 oikos_id, uint8 old_status, uint8 new_status);
    event OikosTokenReminting(uint256 oikos_id, address old_owner_address, address new_owner_address);

    uint256 last_oikos_id;

    mapping (uint256 => uint16) OikosToPolis;

    // Statuses: 0 - token deactivated, 1 - in property, 2 - is being used, 3 - on sale, 4 - in project
    uint8 num_statuses = 4;
    mapping (uint256 => uint8) OikosToStatus; 

    mapping (uint256 => bool) RemintingPermission;
    

    constructor() ERC721("OikosToken", "OKST") Ownable(msg.sender) {
        last_oikos_id = 1; 
    }

    // 1. tokenURI override
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    // 2. supportsInterface override
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }


    function create_new_oikos(address _to, string memory _tokenURI, uint16 _parent_polis_id, uint8 _status) public onlyOwner {
        _safeMint(_to, last_oikos_id); 
        OikosToStatus[last_oikos_id] = _status;
        OikosToPolis[last_oikos_id] = _parent_polis_id;
        _setTokenURI(last_oikos_id, _tokenURI);
        last_oikos_id++;  
    }

    function change_oikos_token_uri(uint256 _oikos_id, string memory _tokenURI) public onlyOwner {
        _setTokenURI(_oikos_id, _tokenURI);
    }

    function get_oikos_token_uri(uint256 _oikos_id) public view returns (string memory) {
        return (
            tokenURI(_oikos_id)
            );
    }

    function get_parent_polis(uint256 _oikos_id) public view returns (uint16) {
        return OikosToPolis[_oikos_id];
    }

    function set_oikos_status(uint256 _oikos_id, uint8 _newStatus) public onlyOwner {
        require(OikosToStatus[_oikos_id] > 0 && _newStatus <= num_statuses);
        emit OikosStatusChanging(_oikos_id, OikosToStatus[_oikos_id], _newStatus);
        OikosToStatus[_oikos_id] = _newStatus;
    }

    function set_num_statuses(uint8 _new_val) public onlyOwner {
        num_statuses = _new_val;
    }

    function set_reminting_permission(uint256 _oikos_id, bool _perm) public {
        require(msg.sender == ownerOf(_oikos_id));
        RemintingPermission[_oikos_id] = _perm;
    }

    // In case if owner lost access to his private key we can "remint" his token
    function remint_oikos_token(uint256 _oikos_id, address _newOwnerAddress) public onlyOwner {
        require(OikosToStatus[_oikos_id] > 0 && RemintingPermission[_oikos_id] == true);
        uint8 act_status = OikosToStatus[_oikos_id];
        emit OikosTokenReminting(_oikos_id, ownerOf(_oikos_id), _newOwnerAddress);
        OikosToStatus[_oikos_id] = 0; // deactivate token
        create_new_oikos(_newOwnerAddress, tokenURI(_oikos_id), OikosToPolis[_oikos_id], act_status);
    }

}