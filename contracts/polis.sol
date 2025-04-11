// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./oikos.sol";

contract Polis is Oikos {

    event NewPolis(uint16 polis_id, uint8 parent_unity_id);
    event ParentUnityChanging(uint16 polis_id, uint8 old_parent_unity_id, uint8 new_parent_unity_id);

    uint16 public last_polis_id;

    mapping (uint16 => uint8) PolisToUnity;

    function create_new_polis(uint8 _parent_unity_id) public onlyOwner {
        PolisToUnity[last_polis_id] = _parent_unity_id;
        emit NewPolis(last_polis_id, _parent_unity_id);
        last_polis_id++;  
    }


    function get_parent_unity(uint16 _polis_id) public view returns (uint8) {
        return (
            PolisToUnity[_polis_id]
        );
    }

    function set_parent_unity(uint16 _polis_id, uint8 _parent_unity_id) public onlyOwner {
        emit ParentUnityChanging(_polis_id, PolisToUnity[_polis_id], _parent_unity_id);
        PolisToUnity[_polis_id] = _parent_unity_id;
    }

    function get_oikos_list(uint16 _polis_id, uint16 _n_oikos, uint8 _min_status, uint8 _max_status) public view returns (uint32[] memory) {
        uint32[] memory oikos_list = new uint32[](_n_oikos);
        uint32 counter = 0;
        for (uint32 i=0; i<last_oikos_id; i++) {
            if (OikosToPolis[i] == _polis_id && OikosToStatus[i] >= _min_status && OikosToStatus[i] <= _max_status) {
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