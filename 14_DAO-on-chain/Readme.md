<h1> DAO Project </h1>

This is an on-chain goverance DAO standard based on ERC20 tokens, used for voting, creating and execution of the propsals for a community.

This project has 4 smart contracts written in solidity, viz. Box, GovernanceToken, GovernorContract and TimeLock.

- The Box is the contract which we want to govern over. It is a simple contract that stores a value and allows it to be retrieved later.

- The GovernanceToken is an ERC20 token contract, the holders of which will be able to vote. We're using a special OpenZepplin contract called 'ERC20Votes' to enable voting through ERC20 tokens.

- The third contract is the GovernorContract, which contains all the voting logic to maintain the functionality of DAO. It is this contract that creates a new proposal, and if it passes, the proposal is sent to the TimeLock contract.

- The fourth contract is the TimeLock contract, which is the true owner of the Box contract. In order to do any changes to the Box contract, we have to go through the TimeLock contract.

<br>

## Compilation

### npx hardhat compile

<br>

## Hardhat deploy package

A Hardhat Plugin For Replicable Deployments And Easy Testing. This creates a seperate folder for all the deploy scripts, and allows to deploy them on localhost network of Hardhat sequentially.

### npm install --save-dev @nomiclabs/hardhat-ethers@npm:hardhat-deploy-ethers ethers

### npm install --save-dev hardhat-deploy

<br>

Example of deploy script:

```js
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  // code here
};
export default func;
```

<br>

## Add Typescript support

### npm install --save-dev typescript typechain ts-node @typechain/ethers-v5 @typechain/hardhat @types/chai @types/node

## Deploy on localhost for testing

### npx hardhat deploy

## Run Scripts

-TESTING:

### npx hardhat node

### npx hardhat run scripts/propose.ts --network localhost

### npx hardhat run scripts/vote.ts --network localhost

### npx hardhat run scripts/queue-and-execute.ts --network localhost
