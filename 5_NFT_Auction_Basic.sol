// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IERC721{
    function transfer(address, uint) external; //It takes a specific address on to which we need to transfer an NFT, and the NFT_ID.
    function transferFrom(address, address, uint) external; //sender, receiver, NFT_ID
}

contract Auction {
    //STATE VARIABLES.
    address payable public seller;
    bool public started;
    bool public ended;
    uint public endAt;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public bids;

    IERC721 public nft; //Defining the NFT that we're auctioning.
    uint public nftId;    

    constructor () 
    {
        seller = payable(msg.sender);
    }
    
    //EVENTS.
    event Start();
    event Bid(address indexed sender, uint amount);
    event Withdraw(address indexed bidder, uint amount);
    event End(address highestBidder, uint highestBid);    
    
    
    //FUNCTIONS.

    //This start() takes as input, the contract address of the NFT, the NFT_ID and the starting bid.
    function start(IERC721 _nft, uint _nftId, uint startingBid) external 
    {
        require(!started, "Already started!"); 
        require(msg.sender == seller, "You did not start the auction!");
        highestBid = startingBid;

        nft = _nft;
        nftId = _nftId;
        
        nft.transferFrom(msg.sender, address(this), nftId); //we're transfering nft from msg.sender to  this auction contract.

        started = true; 
        endAt = block.timestamp + 2 days;
        emit Start();
    }

    function bid() external payable 
    {
        require(started, "Not started.");
        require(block.timestamp < endAt, "Ended!");
        require(msg.value > highestBid); 

        if (highestBidder != address(0)) 
        {
            bids[highestBidder] += highestBid; 
        }
        highestBid = msg.value;
        highestBidder = msg.sender; 
        emit Bid(highestBidder, highestBid);
    }

    function withdraw() external payable 
    {
        uint bal = bids[msg.sender];
        bids[msg.sender] = 0;
        
        (bool sent, bytes memory data) = payable(msg.sender).call{value: bal}("");
        require(sent, "Could not withdraw");
        
        emit Withdraw(msg.sender, bal);
    }

    function end() external 
    {
        require(started, "You need to start first!");
        require(block.timestamp >= endAt, "Auction is still ongoing!");
        require(!ended, "Auction already ended!");

        if (highestBidder != address(0)) {
            nft.transfer(highestBidder, nftId);//Transfering the NFT to the winner.
            
            (bool sent, bytes memory data) = seller.call{value: highestBid}("");// Paying the seller.
            require(sent, "Could not pay seller!");
        } else {
            nft.transfer(seller, nftId); //Transfering to the seller.
        }

        ended = true;
        emit End(highestBidder, highestBid);
    }
}
