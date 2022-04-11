//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract MyVestingToken is ERC20 {
  constructor() ERC20('My Vesting Token', 'MVT') {
    _mint(msg.sender, 1000000000000 * 10 ** 18);
  }
}

