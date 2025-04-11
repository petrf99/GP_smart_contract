// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract GenesisShares is ERC721, ERC721URIStorage, Ownable {

    uint256 last_share_id;
    
    mapping (uint256 => string) ShareToStakeSerNum;

    constructor() ERC721("GenesisShareToken", "GSHT") Ownable(msg.sender) {
        last_share_id = 1; 
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    // 2. supportsInterface override
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function change_share_token_uri(uint256 _share_id, string memory _tokenURI) public onlyOwner {
        _setTokenURI(_share_id, _tokenURI);
    }

    function get_share_token_uri(uint256 _share_id) public view returns (string memory) {
        return (
            tokenURI(_share_id)
            );
    }

    function create_new_share(address _to, string memory _stake_ser_num) public onlyOwner {
        _safeMint(_to, last_share_id); 
        ShareToStakeSerNum[last_share_id] = _stake_ser_num;
        last_share_id++;  
    }

}