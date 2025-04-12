// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./oikos.sol";

/// @title Polis Smart Contract
/// @notice Smart Contract representing Polis as a group of Oikoses.
/// @dev Inherits from Oikos contract.
contract Polis is Oikos {
    event NewPolis(uint16 polisId, uint8 parentUnityId);
    event ParentUnityChanging(uint16 polisId, uint8 oldParentUnityId, uint8 newParentUnityId);

    uint16 public nextPolisId;

    /// @dev Polis-specific metadata URI, separate from parent Oikos contract.
    string private _contractURI;

    /// Unities of Polises (if exist)
    mapping(uint16 => uint8) polisToUnity;

    /// @notice Sets _contractURI.
    /// @param _initContractURI Metadata URI for whole contract.
    /// @dev Overrides parent contract URI with Polis-specific metadata.
    constructor(string memory _initContractURI) Oikos(_initContractURI) {
        _contractURI = _initContractURI;
    }

    /// @notice Create New Polis.
    /// @param _parentUnityId Id of Unity (if exists, can be empty).
    /// @dev onlyOwner.
    function createNewPolis(uint8 _parentUnityId) public onlyOwner {
        polisToUnity[nextPolisId] = _parentUnityId;
        emit NewPolis(nextPolisId, _parentUnityId);
        nextPolisId++;
    }

    /// @notice Get Unity for given Polis.
    /// @param _polisId Id of the Polis.
    function getParentUnity(uint16 _polisId) public view returns (uint8) {
        return polisToUnity[_polisId];
    }

    /// @notice Change Unity for given Polis.
    /// @param _polisId Id of the Polis.
    /// @param _parentUnityId New Unity Id.
    function setParentUnity(uint16 _polisId, uint8 _parentUnityId) public onlyOwner {
        emit ParentUnityChanging(_polisId, polisToUnity[_polisId], _parentUnityId);
        polisToUnity[_polisId] = _parentUnityId;
    }

    /// @notice Get list of Oikoses which form given Polis.
    /// @param _polisId Id of the Polis.
    /// @param _nOikos Number of Oikoses to get.
    /// @param _minStatus Minimal status of Oikos to be listed (if needed to filter).
    /// @param _maxStatus Max status of Oikos to be listed (if needed to filter).
    /// @return uint256[] List of Oikoses.
    function getOikosList(uint16 _polisId, uint16 _nOikos, uint8 _minStatus, uint8 _maxStatus)
        public
        view
        returns (uint256[] memory)
    {
        uint256[] memory oikosList = new uint256[](_nOikos);
        uint256 counter = 0;
        for (uint32 i = 0; i < nextOikosId; i++) {
            if (oikosToPolis[i] == _polisId && oikosToStatus[i] >= _minStatus && oikosToStatus[i] <= _maxStatus) {
                oikosList[counter] = i;
                counter++;
            }
            if (counter == _nOikos) {
                break;
            }
        }
        return (oikosList);
    }

    /// @notice Returns whole contract metadata URI.
    function contractURI() public view override returns (string memory) {
        return _contractURI;
    }

    /// @notice Change _contractURI.
    /// @param _newContractURI New value for _contractURI.
    function setContractURI(string memory _newContractURI) public override onlyOwner {
        _contractURI = _newContractURI;
        emit ContractURIUpdated(_contractURI);
    }
}
