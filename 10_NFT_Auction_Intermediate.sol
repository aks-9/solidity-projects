// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; //Security measure against re-entrancy attack.


contract nftMarketplace is ReentrancyGuard {

  using Counters for Counters.Counter;
  Counters.Counter private _itemIds;
  Counters.Counter private _itemsSold;

  address payable owner;
  uint listingFee = 0.001 ether;

  constructor() {
    owner = payable(msg.sender);
  }

  //This will hold data of each nft available on the marketplace.
  struct MarketItem {
    uint marketItemId;    
    uint tokenId;
    uint price;

    address payable seller;
    address payable owner;
    address nftContract;
    
  }

  mapping(uint => MarketItem) private allMarketItems; //a mapping to point to our structure marketItem. It will take marketItemId as an input.

  event MarketItemCreated (uint indexed marketItemId,address indexed nftContract, uint indexed tokenId, address seller, address owner, uint price);

  // modifier onlyManger(){
  //  require(msg.sender== seller,"Only manager can call this function");
  //       _;
  //   }

  // modifier onlyBuyer(){
  //   require();
  //   _;
  // }

  

    //For listing an item on the marketplace.
    //Using a modifier from the imported ReentrancyGuard contract.
    function createMarketItem(address _nftContract, uint _tokenId, uint _price) public payable nonReentrant {
    require(_price > 0, "Listing price must be greater than zero.");
    require(msg.value == listingFee, "Minimum listing price of 0.001 ETH not met.");

    _itemIds.increment(); //incrementing our counter.
    uint marketItemId = _itemIds.current(); //storing current value of counter in a new local variable.
  
    //Initializing the structure MarketItem, and saving it in allMarketItems mapping with our local variable passed as an argument.
    allMarketItems[marketItemId] =  MarketItem(
      marketItemId,
      _tokenId,
      _price,

      payable(msg.sender), //Only seller will be able to create items to sell.
      payable(address(0)), //setting the owner's address to zero, as it still need to be sold on marketplace.
      _nftContract      
    );

    IERC721(_nftContract).transferFrom(msg.sender, address(this), _tokenId);

    emit MarketItemCreated(marketItemId, _nftContract, _tokenId, msg.sender, address(0), _price);
  }

   //To get a specific marketItem from marketplace, this function returns a structure 'marketItem' on _marketItemId input.
   function getMarketItem(uint marketItemId) public view returns (MarketItem memory) {
    return allMarketItems[marketItemId];
  }

  //For buyers, To make a sale of NFT market item created.
  function createMarketSale(address _nftContract, uint _marketItemId) public payable nonReentrant{
    uint price = allMarketItems[_marketItemId].price;
    uint tokenId = allMarketItems[_marketItemId].tokenId;
    require(msg.value == price, "Must submit asking price to purchase");

    allMarketItems[_marketItemId].seller.transfer(msg.value); //transferring the sale amount to seller.
    IERC721(_nftContract).transferFrom(address(this), msg.sender, tokenId); //sednding the NFT to buyer.

    allMarketItems[_marketItemId].owner = payable(msg.sender); //Updating the ownership in local mapping to msg.sender.
    
    _itemsSold.increment();
    payable(owner).transfer(listingFee); //Transfering the listing fee to the owner of the marketplace. This currently set to 0.001 ETH but it could also be in percentage terms.

  }

  
  // To get all of the items currently for sale.
   function fetchMarketItem() public view returns(MarketItem[] memory) {
     uint itemCount = _itemIds.current(); //Total number of items created so far.
     uint unsoldItemCount = itemCount - _itemsSold.current(); //Total - sold.
     uint currentIndex = 0; // for looping over total number of items in order to get the current index in order to populate an array.

     MarketItem[] memory items = new MarketItem[](unsoldItemCount); //creating a variable called items, it is going to hold an array of market items. And we'll be setting it to a new array with the length of the unsold items length. So we know that we want to only return the items that are unsold.

     for (uint i = 0; i < itemCount; i++)
     {//looping over the entire total items
      if (allMarketItems[i + 1].owner == address(0))
      { //checking to see if the address is an empty address. If address is an empty address, that means this item is yet to be sold, and we do want to return it. If it is not an empty address, we don't want to return it.

        //uint currentID =idToMarketItem[i+1].itemId; // If the address is an empty address, we created an item called currentID and we set that to the value of this idToMarketItem mapping.
        //the index is starting at zero but our counter started at one so we're  going to say index plus one.
        uint currentId = i + 1;

        MarketItem storage currentItem = allMarketItems[currentId]; //and then we create an another variable called current item and we set the value of this items array the value of that item.

        items[currentIndex] = currentItem;
        currentIndex += 1; //then increment the value of our current index by one because we started that index at zero and we're going to be adding a new item maybe on the next loop so we want to increment that. 

        //the index of MarketItem[] array of course is going to start as an empty array and we're going to populate it with the zeroth item, the first time the code under for loop is called.And then we  increment that to one and the next time    this is called the current index is one and so on and so forth. 
        
        //Then all we want to do at this point is, we've populated the array at that point we're just going to return the items, so  this will return the market items that have not yet been sold.
      }
     }
  return items;

  }



    function fetchMyNFTs() public view returns (MarketItem[] memory) {
    uint totalItemCount = _itemIds.current();
    uint itemCount = 0;
    uint currentIndex = 0;

    for (uint i = 0; i < totalItemCount; i++) {
      if (allMarketItems[i + 1].owner == msg.sender) {
        itemCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint i = 0; i < totalItemCount; i++) {
      if (allMarketItems[i + 1].owner == msg.sender) {
        uint currentId = i + 1;
        MarketItem storage currentItem = allMarketItems[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }

    return items;
  }

    

  

 
}
                                   
