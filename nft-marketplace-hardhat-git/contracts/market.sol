//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./nft.sol";
import "./currency.sol";
import "./fractional.sol";


contract NFTmarketplace {
    
    address public admin;
    uint public platformCommission;
    uint royaltyPercentage = 1; // One percent of Currency tokens, when fractional ERC20 tokens are redeemed for Currency ERC20 tokens.
    uint royalty; //amount to be transfered to each fractional ERC20 tokens holder.

    CurrencyToken currencyToken; //instance of CurrencyToken contract.
    NFTtoken  nft; //instance of NFTtoken contract.
    fractionalNFT  fnft; //instance of fractionalNFT contract.
     

   // For Fractional ERC20 tokens
    mapping(address => uint) public holders; //points to number of tokens held by an address
    address[] public listOfHolders; //addresses of holders
    uint public numOfHolders = listOfHolders.length;
    uint holderId; 
  
    mapping(uint => bool) public tokenIdForSale; //tokenID is listed on sale or not   
    mapping(uint => address) public nftBuyers; 
    mapping(uint => address) public nftSellers; 
    
    
    constructor (address _currencyTokenAddress, address _nftAddress, address _fractionalNFT) {
        admin = payable(msg.sender);
        platformCommission = 25; // should be 2.5 percent but uint can't be a decimal.
        currencyToken = CurrencyToken(_currencyTokenAddress);
        nft = NFTtoken(_nftAddress);
        fnft = fractionalNFT(_fractionalNFT);
    }
    
    // To put an NFT on sale
    function Sale(uint _tokenId, uint _nftPriceNew) external {
        require(msg.sender == nft.ownerOf(_tokenId),"Only owner can put the NFTs on sale");        
        require(_nftPriceNew != nft.tokenPrice(_tokenId));

        tokenIdForSale[_tokenId] = true;
        nftSellers[_tokenId] = msg.sender;

             
        nft.transferFrom(msg.sender, address(this), _tokenId); //sending nft from creator to marketplace
        nft.setTokenPrice(_tokenId, _nftPriceNew); //setting the new price 
    }
    
   
    // To purchase an NFT available on marketplace for sale.
    function Buy(uint _tokenId) public {

        require(tokenIdForSale[_tokenId],"NFT must be put on sale by the owner first!");      
        
        uint nftPrice = nft.tokenPrice(_tokenId); 
        address nftSeller = nftSellers[_tokenId];       
        
        require(currencyToken.allowance(msg.sender, address(this)) >= nftPrice, "Insufficient allowance!");
        require(currencyToken.balanceOf(msg.sender) >= nftPrice, "Insufficient balance!");

        uint commission = (platformCommission * nftPrice) / 1000; //dividing by 1000 as platformCommission is 25, but has to be 2.5%
        currencyToken.transferFrom(msg.sender, admin, commission); //Transfering the platform's commission in terms of ERC20 currency tokens, to the admin of the marketplace.

        uint creatorShare = ((1000 - platformCommission) * nftPrice) / 1000;
        currencyToken.transferFrom(msg.sender, nftSeller, creatorShare); // sending ERC20 currency tokens to NFT creator.

        nft.transferFrom(address(this), msg.sender, _tokenId); // sending the NFT from marketplace to buyer      
        
        nftBuyers[_tokenId] = msg.sender;
        
    }

    // To put a Fractional NFT on sale
    function fractionalSale(uint _tokenId) external {
        require(msg.sender == nft.ownerOf(_tokenId),"Only owners can put their NFT on sale");
        tokenIdForSale[_tokenId] = true;
        nftSellers[_tokenId] = msg.sender;
        
        nft.transferFrom(msg.sender, address(this), _tokenId); //sending nft from creator to marketplace
        
    }


    // To purchase a fraction of an NFT available on marketplace for sale.
    function fractionalBuy(uint _tokenId, uint _parts) public {
        require(tokenIdForSale[_tokenId],"NFT must be put on sale by owner first!");
        require(_parts > 0,"NFT fractions to be purchased has to be between 1 to 100");      
        
        uint nftPrice = nft.tokenPrice(_tokenId);
        uint fractionalNftPrice =  nftPrice / 100 * _parts ; 

        address nftSeller = nftSellers[_tokenId];       
        
        require(currencyToken.allowance(msg.sender, address(this)) >= fractionalNftPrice, "Insufficient allowance!");
        require(currencyToken.balanceOf(msg.sender) >= fractionalNftPrice, "Insufficient balance!");

        uint commission = (platformCommission * fractionalNftPrice) / 1000; //dividing by 1000 as platformCommission is 2.5% but uint can't be a decimal.
        currencyToken.transferFrom(msg.sender, admin, commission); //Transfering the platform commission to the admin of the marketplace.

        uint creatorShare = ((1000 - platformCommission) * fractionalNftPrice) / 1000;

        currencyToken.transferFrom(msg.sender, nftSeller, creatorShare); // sending ERC20 tokens to NFT owner.
        //fnft.transferFrom(address(this), msg.sender, _parts); // sending the fractional ERC20 tokens from marketplace to fractional buyer      
        
        nftBuyers[_tokenId] = msg.sender;




        if( holders[msg.sender] == 0 ) {

            listOfHolders.push(msg.sender);
            holders[msg.sender] = _parts;
            
            holderId = holderId + 1;
            numOfHolders = numOfHolders + 1;

        } else {
            holders[msg.sender] = holders[msg.sender] + _parts;
        }       
        
    }

    function Redeem(uint _tokensFNFTtoSell, uint _tokenId) public {
        require(fnft.balanceOf(msg.sender) >= _tokensFNFTtoSell,"Insufficient balance to redeem");

        
        fnft.transferFrom(msg.sender, address(this), _tokensFNFTtoSell);//sending fractionalNFT tokens from seller to this contract.

        if( holders[msg.sender] <= 0 ) {
            listOfHolders.pop(); //removing the holder address if sold all fractional tokens.
            numOfHolders = numOfHolders - 1; //decrementing the number of current holders
                        
        } else {
            holders[msg.sender] = holders[msg.sender] - _tokensFNFTtoSell; //removing number of sold fractions
        }

        uint nftPrice = nft.tokenPrice(_tokenId); 
        uint priceOfOneFNFTtoken = nftPrice / 100;
        uint amount = priceOfOneFNFTtoken * _tokensFNFTtoSell;

        uint _royalty = amount * royaltyPercentage / 100;
        uint amountAfterRoyalty = amount - _royalty ;
        currencyToken.transferFrom(address(this), msg.sender, amountAfterRoyalty); //sending currency ERC20 tokens to the redeemer.
        royalty = _royalty;

        transferRoyalty(); //sending royalty to fractional ERC20 token holders.

    }

    function transferRoyalty() public {
        address currentAddress;
        uint royaltyPerHolder = royalty / numOfHolders;
        for (uint i=0; i< listOfHolders.length; i++) {
             currentAddress = listOfHolders[i];
             currencyToken.transferFrom(address(this), currentAddress, royaltyPerHolder);
            }
    }

    

    // function holdersToValue() public view {
    //     uint currentValue;
    //     for (uint i=0; i< listOfHolders.length; i++) {
    //          currentValue = holders[listOfHolders[i]];
    //     }
    // }
    

}

