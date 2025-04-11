// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./oikos.sol";

contract Polis is Oikos {

    event NewPolis(uint16 polis_id, string name, string center_geo_coordinates, uint8 parent_unity_id);
    event ParentUnityChanging(uint16 polis_id, uint8 old_parent_unity_id, uint8 new_parent_unity_id);

    uint16 public last_polis_id;

    mapping (uint16 => uint8) PolisToUnity;
    mapping (uint16 => string) PolisToGeoCoordinates;
    mapping (uint16 => string) PolisToName;
    mapping (uint16 => string) PolisToInfoLink;

    function create_new_polis(string memory _name, uint8 _parent_unity_id, string memory _info_link, string memory _center_geo_coordinates) public onlyOwner {
        PolisToGeoCoordinates[last_polis_id] = _center_geo_coordinates;
        PolisToUnity[last_polis_id] = _parent_unity_id;
        PolisToName[last_polis_id] = _name;
        PolisToInfoLink[last_polis_id] = _info_link;

        emit NewPolis(last_polis_id, _name, _center_geo_coordinates, _parent_unity_id);
        last_polis_id++;  
    }


    function get_polis_info(uint16 _polis_id) public view returns (string memory, string memory, string memory, uint8) {
        return (
            PolisToGeoCoordinates[_polis_id],
            PolisToName[_polis_id],
            PolisToInfoLink[_polis_id],
            PolisToUnity[_polis_id]
        );
    }

    function set_parent_unity(uint16 _polis_id, uint8 _parent_unity_id) public onlyOwner {
        emit ParentUnityChanging(_polis_id, PolisToUnity[_polis_id], _parent_unity_id);
        PolisToUnity[_polis_id] = _parent_unity_id;
    }

    function get_oikos_list(uint16 _polis_id, uint16 _n_oikos, uint8 min_status, uint8 max_status) public view returns (uint32[] memory) {
        uint32[] memory oikos_list = new uint32[](_n_oikos);
        uint32 counter = 0;
        for (uint32 i=0; i<last_oikos_id; i++) {
            if (OikosToPolis[i] == _polis_id && OikosToStatus[i] >= min_status && OikosToStatus[i] <= max_status) {
                oikos_list[counter] = i;
                counter++;
            }
            if (counter == _n_oikos) {
                break;
            }
        }
        return (oikos_list);
    }


}