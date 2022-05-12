// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract BlazeToken is Ownable, ERC20 {

    constructor(
        string memory _tokenName,
        string memory _tokenSymbol
    ) ERC20(_tokenName, _tokenSymbol) {}

    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount * 10**decimals());
    }
}
