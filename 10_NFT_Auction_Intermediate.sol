// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol"; //counter utility to create and increment tokenID
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol"; // allow access to setTokenURI() to set an IPFS URI for storing NFT's .JSON file.
import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; //gives access you reentrancy security.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol"; // Original NFT721 standard.

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds; //default is set to 0.
    address contractAddress; //For us to interact from one contract to another, we're going to need to call this function setApprovalForAll() from within the ERC721 digital item.

    //setApprovalForAll() allows us to pass in the contract address that we want to give permission, to make transfers on behalf of. That means first we've to pass the contract address of the marketplace fro approval, before we can transfer this NFT digital item.

    // So we've to deploy our marketplace address first.

    constructor(address marketplaceAddress) ERC721("NFT Marketplace Intermediate", "NMI") {
        contractAddress = marketplaceAddress;
    }

    function createToken(string memory tokenURI) public returns (uint) {
        _tokenIds.increment(); //Incrementing as we're creating a new NFT.
        uint256 newItemId = _tokenIds.current(); //storing the incremented tokenID value of new NFT.

        _mint(msg.sender, newItemId); //Minting a new NFT.
        _setTokenURI(newItemId, tokenURI); //Setting the URI of newly minted NFT.
        setApprovalForAll(contractAddress, true); //Allowing access of this newly minted NFT to the marketplace, so that we can transfer it to a bid winner.
        return newItemId; //So that our frontend application can know which token has been minted.
    }
}



contract NFTMarket is ReentrancyGuard {
  using Counters for Counters.Counter;
  Counters.Counter private _itemIds; //unique identifier for every marketplace item.
  Counters.Counter private _itemsSold;
  //These allow us to know how many items have not been sold by subtracting _itemsSold from _itemsIDs. This is important because if we want to return different views of our data, we need to be able to populate an array with structs and you can't do this with a dynamic array in solidity, you need to know the length.

  //So by having the items sold we can now have items sold, the number of items not sold as well as the total number of items, and then we can know the length of these different arrays that we are going to populate.

  address payable owner;
  uint256 listingPrice = 0.1 ether; //minimum listing price.

  constructor() {
    owner = payable(msg.sender);
  }

  struct MarketItem {
    uint itemId;
    address nftContract;
    uint256 tokenId;
    address payable seller;
    address payable owner; //owner will be set to 0 initially.
    uint256 price;
  }

  mapping(uint256 => MarketItem) private idToMarketItem; //creating a new mapping called idToMarketItem to pass an id to return a market item. To retrieve the meta data of an item, based on its id.

  //When a new items is created.
  event MarketItemCreated (
    uint indexed itemId,
    address indexed nftContract,
    uint256 indexed tokenId,
    address seller,
    address owner,
    uint256 price
  );

  function getMarketItem(uint256 marketItemId) public view returns (MarketItem memory) {
    return idToMarketItem[marketItemId];
  }

  //Function to put a market item for sale.
  function createMarketItem(address nftContract, uint256 tokenId, uint256 price) public payable nonReentrant {
    require(price > 0, "Price must be at least 1 wei");//to put on sale, it must have a value.
    require(msg.value == listingPrice, "Price must be equal to listing price");

    _itemIds.increment(); //id for market item.
    uint256 itemId = _itemIds.current();

    idToMarketItem[itemId] =  MarketItem( //initializing the struct.
      itemId,
      nftContract,
      tokenId,
      payable(msg.sender),
      payable(address(0)), //no owner yet, setting it to an empty address.
      price
    );

    IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);// Transfering the ownership of NFT from seller to marketplace.

    emit MarketItemCreated(itemId, nftContract, tokenId, msg.sender, address(0), price);
  }


  //FOr buyers, To make a sale of NFT market item created.
  function createMarketSale(address nftContract, uint256 itemId) public payable nonReentrant {
    uint price = idToMarketItem[itemId].price;
    uint tokenId = idToMarketItem[itemId].tokenId;
    require(msg.value == price, "Please submit the asking price in order to complete the purchase");

    idToMarketItem[itemId].seller.transfer(msg.value);// sending the amount of purchase to seller.
    IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId); //sednding the NFT to buyer.

    idToMarketItem[itemId].owner = payable(msg.sender); //Updating the ownership in local mapping to msg.sender.
    _itemsSold.increment();
    payable(owner).transfer(listingPrice); //Transfering the listing fee to the owner of the marketplace. This currently set to 0.1 ETH but it could also be in percentage terms.
  }

  // To get all of the items currently for sale.
  function fetchMarketItems() public view returns (MarketItem[] memory) {
    uint itemCount = _itemIds.current(); //Total number of items created so far.
    uint unsoldItemCount = itemCount - _itemsSold.current(); //Total - sold
    uint currentIndex = 0; // for looping over total number of items in order to get the current index in order to populate an array.

    MarketItem[] memory items = new MarketItem[](unsoldItemCount); //creating a variable called items, it is going to hold an array of market items. And we'll be setting it to a new array with the length of the unsold items length. So we know that we want to only return the items that are unsold.


    for (uint i = 0; i < itemCount; i++) {//looping over the entire total items.
      if (idToMarketItem[i + 1].owner == address(0)) { //checking to see if the address is an empty address. If address is an empty address, that means this item is yet to be sold, and we do want to return it. If it is not an empty address, we don't want to return it.

        //uint currentID =idToMarketItem[i+1].itemId; // If the address is an empty address, we created an item called currentID and we set that to the value of this idToMarketItem mapping.
        //the index is starting at zero but our counter started at one so we're  going to say index plus one.
        uint currentId = i + 1;

        MarketItem storage currentItem = idToMarketItem[currentId]; //and then we create an another variable called current item and we set the value of this items array the value of that item.

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
      if (idToMarketItem[i + 1].owner == msg.sender) {
        itemCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].owner == msg.sender) {
        uint currentId = i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }

    return items;
  }
}
