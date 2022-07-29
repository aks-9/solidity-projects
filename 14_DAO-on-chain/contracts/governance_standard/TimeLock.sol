// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/governance/TimelockController.sol"; //This contract allows us to set ROLES like Admin, Proposer, Executor etc.

//* This TimeLock contract is actually going to be the owner of the Box contract. Whenever we want to create a proposal or queue it, we must wait. We want to wait for a new vote to be executed. This allows users to leave before changes are live, if they don't like a governance update. So whenver a proposal passes, it won't go in effect right away, it has to wait for some duration before it goes into effect.

contract TimeLock is TimelockController {
    constructor(
        uint256 minDelay, // minDelay is how long you have to wait after a proposal passes, before executing it.
        address[] memory proposers, // proposers is the list of addresses that can propose
        address[] memory executors // executors is the list of addresses that can execute a proposal after it has passed.
    ) TimelockController(minDelay, proposers, executors) {}
}
