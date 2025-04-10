// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Oikos is ERC721, Ownable {

    event OikosOwnerChanging(uint32 oikos_id, address old_owner, address new_owner);
    event OikosStatusChanging(uint32 oikos_id, uint8 old_status, uint8 new_status);

    uint32 last_oikos_id;
    
    mapping (uint32 => address) OikosToOwner;
    mapping (uint32 => uint16) OikosToPolis;
    mapping (uint32 => string) OikosToGeoCoordinates;

    // Statuses: 1 - in property, 2 - on sale, 3 - is being used, 4 - in project
    mapping (uint32 => uint8) OikosToStatus; 
    

    constructor() ERC721("OikosToken", "OKST") Ownable(msg.sender) {
        last_oikos_id = 1; 
    }

    function create_new_oikos(address _to, uint16 _parent_polis_id, string memory _center_geo_coordinates, uint8 _status) public onlyOwner {
        _safeMint(_to, last_oikos_id); 
        OikosToOwner[last_oikos_id] = _to;
        OikosToPolis[last_oikos_id] = _parent_polis_id;
        OikosToGeoCoordinates[last_oikos_id] = _center_geo_coordinates;
        OikosToStatus[last_oikos_id] = _status;
        last_oikos_id++;  
    }

    function get_oikos_info(uint32 _oikos_id) public view returns (string memory, address, uint16, uint8) {
        return (
            OikosToGeoCoordinates[_oikos_id],
            OikosToOwner[_oikos_id],
            OikosToPolis[_oikos_id],
            OikosToStatus[_oikos_id]
            );
    }

    function change_oikos_owner(uint32 _oikos_id, address _newOikosOwner) public {
        require(msg.sender == OikosToOwner[_oikos_id]);
        emit OikosOwnerChanging(_oikos_id, OikosToOwner[_oikos_id], _newOikosOwner);
        OikosToOwner[_oikos_id] = _newOikosOwner;
    }

    function set_oikos_status(uint32 _oikos_id, uint8 _newStatus) public {
        require(msg.sender == OikosToOwner[_oikos_id]);
        emit OikosStatusChanging(_oikos_id, OikosToStatus[_oikos_id], _newStatus);
        OikosToStatus[_oikos_id] = _newStatus;
    }

}