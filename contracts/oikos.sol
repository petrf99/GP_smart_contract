// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Oikos is ERC721, Ownable {

    event NewOikosCreated(uint32 oikos_id, address owner, uint16 parent_polis, string geo_coordinates, uint8 status);
    event OikosOwnerChanging(uint32 oikos_id, address old_owner, address new_owner);
    event OikosStatusChanging(uint32 oikos_id, uint8 old_status, uint8 new_status);
    event OikosOwnerChanged(uint32 oikos_id, address old_owner, address new_owner);
    event OikosTokenReminting(uint32 oikos_id, address old_owner_address, address new_owner_address);

    uint32 last_oikos_id;
    
    mapping (uint32 => address) OikosToOwner;
    mapping (uint32 => uint16) OikosToPolis;
    mapping (uint32 => string) OikosToGeoCoordinates;

    // Statuses: 0 - token deactivated, 1 - in property, 2 - is being used, 3 - on sale, 4 - in project
    uint8 num_statuses = 4;
    mapping (uint32 => uint8) OikosToStatus; 

    mapping (uint32 => address) public ApprovedList;
    

    constructor() ERC721("OikosToken", "OKST") Ownable(msg.sender) {
        last_oikos_id = 1; 
    }

    function create_new_oikos(address _to, uint16 _parent_polis_id, string memory _center_geo_coordinates, uint8 _status) public onlyOwner {
        _safeMint(_to, last_oikos_id); 
        OikosToOwner[last_oikos_id] = _to;
        OikosToPolis[last_oikos_id] = _parent_polis_id;
        OikosToGeoCoordinates[last_oikos_id] = _center_geo_coordinates;
        OikosToStatus[last_oikos_id] = _status;
        emit NewOikosCreated(last_oikos_id, _to, _parent_polis_id, _center_geo_coordinates, _status);
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

    function send_new_oikos_ownership(uint32 _oikos_id, address _newOikosOwner) public {
        require(msg.sender == OikosToOwner[_oikos_id] && OikosToStatus[_oikos_id] > 0);
        emit OikosOwnerChanging(_oikos_id, OikosToOwner[_oikos_id], _newOikosOwner);
        ApprovedList[_oikos_id] = _newOikosOwner;
    }

    function receive_new_oikos_ownership(uint32 _oikos_id) public {
        require(msg.sender == ApprovedList[_oikos_id] && OikosToStatus[_oikos_id] > 0);
        address old_owner = OikosToOwner[_oikos_id];
        OikosToOwner[_oikos_id] = msg.sender;
        emit OikosOwnerChanged(_oikos_id, old_owner, msg.sender);
    }

    function set_oikos_status(uint32 _oikos_id, uint8 _newStatus) public {
        require(msg.sender == OikosToOwner[_oikos_id] && OikosToStatus[_oikos_id] > 0 && _newStatus <= num_statuses);
        emit OikosStatusChanging(_oikos_id, OikosToStatus[_oikos_id], _newStatus);
        OikosToStatus[_oikos_id] = _newStatus;
    }

    function set_num_statuses(uint8 _new_val) public onlyOwner {
        num_statuses = _new_val;
    }

    // In case if owner lost access to his private key we can "remint" his token
    function replace_oikos_token(uint32 _oikos_id, address _newOwnerAddress) public onlyOwner {
        require(OikosToStatus[_oikos_id] > 0);
        uint8 act_status = OikosToStatus[_oikos_id];
        emit OikosTokenReminting(_oikos_id, OikosToOwner[_oikos_id], _newOwnerAddress);
        OikosToStatus[_oikos_id] = 0; // deactivate token
        create_new_oikos(_newOwnerAddress, OikosToPolis[_oikos_id], OikosToGeoCoordinates[_oikos_id], act_status);
    }

}