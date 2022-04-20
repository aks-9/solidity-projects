# NFT Marketplace project.

This project consists of 4 smart contracts, which enable us to create a NFT Marketplace where a user can mint, sell, and buy and NFT using custom ERC20 tokens used as currency on the marketplace. 

A user can further sell and buy fractional parts of an NFT, by minting ERC20 tokens for their NFT and distributing them to multiple owners as per required percentage. 

When the fractional owner sells the fractional ERC20 tokens of a particular NFT, a royalty percentage will be deducted from the transactional amount and sent to all of the holders of the fractional NFTs at that time.


# Steps:

1. Deploy the custom ERC20 Currency token contract from a Remix account. 

2. Then transfer some ERC20 Currency tokens to a 2nd Remix account(Buyer's). Check with 'balanceOf' function if the Buyer's account has received the Currency tokens. 

3. Deploy the NFT contract from a 3rd Remix account.

4. Then mint an NFT from the Mint function.

5. Pick a 4th Remix account and deploy the Marketplace contract by passing the Currency Token contract address and NFT contract address as arguments.

6. Switch to the Buyer's Remix account, Copy the Marketplace contract's address, and go to ERC20 Currency token's deployed contract, and click the 'approve' function.

7. Switch to NFT minting account, and in the NFT contract, copy and paste the Marketplace address in the 'approve' function's 'to' field, and input the tokenId.


# FOR NORMAL SALE

8. Go in the Sale function, put the minted nft on sale by passing the values of _tokenId and _nftPriceNew. This will transfer the NFT from creator to the Marketplace.

8. Now switch to the Buyer's account, in the Buy function, put the _tokenId of the nft and click transact.

9. The 'nftPrice' will be deducted from Buyer's account in terms of Currency ERC20 Tokens, and the NFT will be transferred from Marketplace to Buyer's acccount. The admin of the marketplace will receive 2.5% of the 'nftPrice' Currency ERC20 tokens as commision, and the NFT seller will get the remaining ERC20 Currency tokens in his account.


# FOR FRACTIONAL SALE

10. Now to put the NFT on a fractional Sale we will call the 'fractionalSale' function. This will transfer the NFT from creator to marketplace.

11. Now deploy the fractionNFT contract from a new address, and this will issue 100 custom ERC20 tokens representing the fractional percentage of NFT ownership. These tokens will be sent to those who purchase the fractional ownership.

12. Go to Buyer's account, and buy the fractional NFT between 1 to 100 parts.

13. The 'nftPrice' will be deducted from Buyer's account in terms of Currency ERC20 Tokens, and the nft will be transferred from marketplace to buyer's acccount. The admin of the marketplace will receive 2.5% of the nftPrice tokens as commision, and the NFT seller will get the remaining ERC20 Currency tokens in his account.

14. Now Fractional nft tokens must be transferred from Fractional nft contract to the Buyer's account.


# FOR REDEEMING FRACTIONAL TOKENS

15. The contract which will execute the Redeem function must be given liquidity interms of Currency ERC20 tokens. Transfer some Currency tokens from the Currency Token contract account to the Marketplace contract.

16. Approve the fractional ERC20 tokens for marketplace, and from the Buyer's account redeem the fractional ERC20 tokens for currency tokens.

17. Royalty will be deducted from the transactional amount in the form of ERC20 currency tokens and sent equally to all the holders of the fractional NFT tokens respective to their holding.


```
