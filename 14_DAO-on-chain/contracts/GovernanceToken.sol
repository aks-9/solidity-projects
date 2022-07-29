// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol"; //This allows us to take snapshots, so that nobody can manipulate by buying tokens just for a proposal and selling them afterwards. A snapshot tells us how many tokens people have at that certain block time. Once a proposal goes through, we pick a snapshot from the past that we want to use. This incentivizes people not to jump in when a propsal is due for voting, and jump out when voting is done.

//So this makes sure, only those can vote that already were part of a DAO before a proposal was made, and not those who came just to manipulate the voting.

//ERC20Votes has a checkpoints function which works like a snapshot.

// This is the ERC20 token to be used for voting.
contract GovernanceToken is ERC20Votes {
    uint256 public s_maxSupply = 1000000000000000000000000; // 1 million

    constructor()
        ERC20("GovernanceToken", "GT")
        ERC20Permit("GovernanceToken")
    {
        //ERC20Permit constructor comes from ERC20Votes.
        _mint(msg.sender, s_maxSupply); //minting all tokens to the deployer
    }

    //* The functions below are overrides required by Solidity.

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20Votes) {
        super._afterTokenTransfer(from, to, amount); //calling the '_afterTokenTransfer' of the ERC20Votes every time we transfer tokens, so that the snapshots are updated.
    }

    function _mint(address to, uint256 amount) internal override(ERC20Votes) {
        super._mint(to, amount); //to update the snapshots
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20Votes)
    {
        super._burn(account, amount); //to update the snapshots
    }
}
