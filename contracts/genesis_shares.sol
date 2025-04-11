// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract GenesisShares is ERC721, Ownable {
    event NewShareCreated(uint32 share_id, address owner, string stake_ser_num);
    event ShareOwnerChanging(uint32 share_id, address old_owner, address new_owner);
    event ShareOwnerChanged(uint32 share_id, address old_owner, address new_owner);

    uint32 last_share_id;
    uint32 last_owned_id;
    uint256 public price_usdc;
    IERC20 public usdc;

    mapping (uint32 => string) ShareToStakeSerNum;
    mapping (uint32 => address) ShareToOwner;
    mapping (uint32 => address) ApprovedList;

    constructor(uint256 _price_usdc, address _initialUsdcAddress) ERC721("GenesisShareToken", "GSHT") Ownable(msg.sender) {
        last_share_id = 1; 
        last_owned_id = 0;
        price_usdc = _price_usdc;
        usdc = IERC20(_initialUsdcAddress);
    }

    function set_price_usdc(uint256 _new_price) public onlyOwner {
        price_usdc = _new_price;
    }

    function setUSDCAddress(address _newUsdc) public onlyOwner {
        require(_newUsdc != address(0), "Invalid USDC address");
        usdc = IERC20(_newUsdc);
    }

    function create_new_share(address _to, string memory _stake_ser_num) public onlyOwner {
        _safeMint(_to, last_share_id); 
        ShareToOwner[last_share_id] = _to;
        ShareToStakeSerNum[last_share_id] = _stake_ser_num;
        emit NewShareCreated(last_share_id, _to, _stake_ser_num);
        last_share_id++;  
    }

    function send_new_share_ownership(uint32 _share_id, address _newShareOwner) public {
        require(msg.sender == ShareToOwner[_share_id]);
        emit ShareOwnerChanging(_share_id, ShareToOwner[_share_id], _newShareOwner);
        ApprovedList[_share_id] = _newShareOwner;
    }

    function receive_new_share_ownership(uint32 _share_id) public {
        require(msg.sender == ApprovedList[_share_id]);
        address old_owner = ShareToOwner[_share_id];
        ShareToOwner[_share_id] = msg.sender;
        emit ShareOwnerChanged(_share_id, old_owner, msg.sender);
    }

    function buyWithUSDC() public {
        require(last_owned_id < last_share_id, "No free shares left");
        last_owned_id++;
        require(usdc.transferFrom(msg.sender, address(this), price_usdc), "USDC transfer failed");
        ShareToOwner[last_owned_id] = msg.sender;
    }
}