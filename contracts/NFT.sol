// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";


contract NFT is ERC1155 {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor(string memory _uriLink)
        ERC1155(_uriLink) {}

    function mintNFT(uint256 _amount) external {
        require(
            _amount > 0,
            "NFT: Token amount cannot be 0."
        );
        _tokenIds.increment();
        _mint(msg.sender, _tokenIds.current(), _amount, "");
    }
    
    function burnNFT(uint256 _id, uint256 _amount) external {
        require(
            _id != 0,
            "NFT: Invalid token id."
        );
        require(
            _amount != 0,
            "NFT: Burn amount cannot be zero."
        );
        _burn(msg.sender, _id, _amount);

    }
}
