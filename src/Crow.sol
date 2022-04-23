// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "../src/Moonbirds.sol";

contract Crow is Ownable {

    Moonbirds public moonbirds;
    mapping(address => mapping(uint256 => uint256)) public userToOffer;

    constructor(address _moonbirds){
        moonbirds = Moonbirds(_moonbirds);
    }

    function recoverBird(uint256 _birdId) onlyOwner external {
        moonbirds.safeTransferWhileNesting(address(this), owner(), _birdId);
    }

    function acceptOffer(uint256 _birdId, address _ownerOfOffer) onlyOwner external {
        uint256 value = userToOffer[_ownerOfOffer][_birdId];
        userToOffer[_ownerOfOffer][_birdId] = 0;
        moonbirds.safeTransferWhileNesting(address(this), _ownerOfOffer, _birdId);
        payable(msg.sender).transfer(value);
    }

    function placeOffer(uint256 _value, uint256 _birdId) payable external {
        require(msg.value == _value, "value not equal");
        userToOffer[msg.sender][_birdId] = _value;
    }

    function cancelOffer(uint256 _birdId) external {
        uint256 value = userToOffer[msg.sender][_birdId];
        userToOffer[msg.sender][_birdId] = 0;
        payable(msg.sender).transfer(value);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    )external returns(bytes4) {
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }
}
