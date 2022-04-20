//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTtoken is ERC721 {
    
    
    uint public nftId;
    string public nameNFT;
    string public nameSymbol;
    string public nftTokenURI;
    string  _baseURIextended;

    mapping(uint => string) public tokenURIExists;   
    mapping(uint => uint) public tokenIdToValue;    
    
    constructor () ERC721("My NFT", "MNFT") {
        nameNFT = "My NFT";
        nameSymbol = "MNFT";
    
    }

    function Mint (string memory _tokenURI, uint _nftPrice) public returns (uint)  {
        require(msg.sender != address(0));
        nftTokenURI = _tokenURI;        
        nftId ++;

        require(!_exists(nftId),"Token already exists");
        
        tokenIdToValue[nftId] = _nftPrice;
        _mint(msg.sender,nftId);
        _setTokenURI(nftId, nftTokenURI);
        
        return nftId;
        
    }

     function setTokenPrice (uint _nftId, uint _nftPrice) public {
        require(msg.sender == ownerOf(_nftId),"Only owner of an NFT can update the price of the NFT"); 
        tokenIdToValue[_nftId] = _nftPrice;
        
    } 
    
    function tokenPrice (uint _tokenID) external view returns (uint nftPrice) {
        require(_exists(nftId),'NO NFT HERE');
        nftPrice = tokenIdToValue[_tokenID]; 
        return nftPrice;
    } 
    
    
    function setBaseURI(string memory baseURI_) external  {
        _baseURIextended = baseURI_;
    }    
    
    function _setTokenURI(uint tokenId, string memory _tokenURI) internal virtual {
        require( _exists(tokenId),"ERC721Metadata: URI set of nonexistent token");
        tokenURIExists[tokenId] = _tokenURI;
    }
    
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }
    
    function tokenURI(uint tokenId) public view virtual override returns (string memory) {
            require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

            string memory _tokenURI = tokenURIExists[tokenId];
            string memory base = _baseURI();
            
            // If there is no base URI, return the token URI.
            if (bytes(base).length == 0) {
                return _tokenURI;
            }
            // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
            if (bytes(_tokenURI).length > 0) {
                return string(abi.encodePacked(base, _tokenURI));
            }
            // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.            
            return string(abi.encodePacked(base, tokenId));
    }  
    
    
}