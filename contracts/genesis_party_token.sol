// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Genesis Participation Project
/// @notice ERC721 token which signs participation in Genesis Project.
/// @dev Uses OpenZeppelin, ERC721URIStorage and Ownable.
contract GenesisParticipationToken is ERC721URIStorage, Ownable {

    event TokenCreated(address indexed to, uint256 indexed tokenId, string partyNumber);
    event BaseURIUpdated(string newBaseURI);
    event ContractURIUpdated(string newContractURI);


    uint256 nextTokenId;
    string private _baseTokenURI;
    string private _contractURI;
    
    mapping (uint256 => string) tokenToPartyNum;

    /// @notice Sets initial _baseURI and _contractURI.
    /// @param _initBaseURI IPFS base URI used for token metadata.
    /// @param _initContractURI Whole contract metadata.
    constructor(string memory _initBaseURI, string memory _initContractURI) ERC721("GenesisParticipationToken", "GPPT") Ownable(msg.sender) {
        nextTokenId = 0; 
        _baseTokenURI = _initBaseURI;
        _contractURI = _initContractURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    /// @notice Change base URI only if no tokens are minted so far.
    /// @param _newBaseURI New base URI.
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        require(nextTokenId == 0, "Too late to change baseURI, tokens have been minted.");
        _baseTokenURI = _newBaseURI;
        emit BaseURIUpdated(_baseTokenURI);
    }

    /// @notice Mints a new GPPT token to the specified address.
    /// @param _to Receiver of token.
    /// @param _partyNum Real-world participant identifier.
    function createNewGPPT(address _to, string memory _partyNum) public onlyOwner {
        require(bytes(_partyNum).length > 0, "Party number must not be empty");
        _safeMint(_to, nextTokenId); 
        _setTokenURI(nextTokenId, string(abi.encodePacked(_baseTokenURI, Strings.toString(nextTokenId), ".json")));
        tokenToPartyNum[nextTokenId] = _partyNum;
        emit TokenCreated(_to, nextTokenId, _partyNum);
        nextTokenId++;  
    }

    /// @notice Returns the real-world participant number associated with the given token ID.
    /// @param _tokenId token ID.
    /// @return The participant number as a string.
    function getPartyNum(uint256 _tokenId) public view returns (string memory) {
        require(_tokenId >=0 && _tokenId < nextTokenId, "Token does not exist");
        return tokenToPartyNum[_tokenId];
    }

    /// @notice Returns whole contract metadata URI.
    function contractURI() public view returns (string memory) {
        return _contractURI;
    }

    /// @notice Change _contractURI.
    /// @param _newContractURI New value for _contractURI. 
    function setContractURI(string memory _newContractURI) public onlyOwner {
        _contractURI = _newContractURI;
        emit ContractURIUpdated(_contractURI);
    }

}
