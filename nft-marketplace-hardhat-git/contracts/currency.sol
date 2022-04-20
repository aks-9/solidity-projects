//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract CurrencyToken is ERC20 {
    
    mapping (address => uint256) public  _balanceOf;
    
    constructor() ERC20("My Custom Currency Token for NFT Marketplace", "CT") {
        _mint(msg.sender, 1000 * 10 ** 18);
    }
    
  
} 

