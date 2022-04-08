Vesting contract.


1. First deploy the Vesting contract using the first Remix account 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 with the following inputs:

_MENTOR: 0xdD870fA1b7C4700F2BD7f44238821C26f7392148
_ADVISOR: 0x583031D1113aD414F02576BD6afaBfb302140225
_PARTNER: 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB
STARTTIME : unix timestamp from epochconvertor.com


2. Then deploy the ERC20 token contract using the second Remix account 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 

3. Now copy the Vesting contract's address, and paste it in the 'approve' function's 'spender' field. In the 'amount' field, input the total number of tokens minted while deploying the token contract.

4. Now go to 'transfer' function and input the Vesting contract's address in the 'to' field, in the 'amount' field, input the total number of tokens minted, and finally click 'transact' to transfer the tokens to the Vesting contract.

5. Now go to Vesting contract's functions, and check the 'getContractBalance' and make sure your tokens have arrived in the vesting contract.

6.Now go to Vesting contract's functions, and check the 'cliffTimeNew', make sure it has passed.

7. Then go to the 'vested' function and input the token address, it will show you the amount of token vested. If it shows '0' then that means cliff hasn't passed.

8. Now switch to the first Remix account as the owner of the Vesting contract, release the vested tokens by calling the function 'release'.

9. Once the vested tokens are released, they need to be claimed by their respective owners. Change to the address of the 'mentor' to claim vested tokens. Now click on the 'claimMentor' function.

10. Then check the 'mentorAmount' to see if the claimed tokens have arrived or not. Repeat the same for 'advisor'

