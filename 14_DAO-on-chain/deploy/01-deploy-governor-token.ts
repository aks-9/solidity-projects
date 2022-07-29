import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
// @ts-ignore 
import { ethers } from "hardhat"; 


const deployGovernanceToken: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  // @ts-ignore
  const { getNamedAccounts, deployments } = hre; //getting these objects from 'hre', which is being updated by 'hardhat-deploy'. We're importing 'getNamedAccounts' from out config file.

  const { deploy, log } = deployments; //getting 'deploy' and 'log' functions from the 'deployments' object.

  const { deployer } = await getNamedAccounts(); // getting the deployer account from our config file, by calling 'getNamedAccounts' function.


  log("Deploying GovernanceToken...");

  // deploying the contract 'GovernanceToken' and passing some arguments.
  const governanceToken = await deploy("GovernanceToken", {
    from: deployer,
    args: [],
    log: true,
  })

  log(`Deployed the contract GovernanceToken at ${governanceToken.address}`);

  await delegate(governanceToken.address, deployer);
  log("Delegated!");
}

//* Nobody has voting power yet when the contract GovernanceToken is deployed, because nobody has tokens delegated to them. So we will delegate tokens to our deployer.

//This gives a 'delegatedAccount' the tokens to vote.
const delegate = async (governanceTokenAddress: string, delegatedAccount: string) => {

  //using 'ethers' to get the contract by passing in its address.
  const governanceToken = await ethers.getContractAt("GovernanceToken", governanceTokenAddress);

  // using 'delegate' method on the 'governanceToken' contract, to delegate tokens to a particular account.
  const tx = await governanceToken.delegate(delegatedAccount);

  await tx.wait(1) //waiting for transaction to be confirmed by 1 block.

  console.log(`Checkpoints: ${await governanceToken.numCheckpoints(delegatedAccount)}`); //using 'numCheckpoints' function from our 'governanceToken' contract, on our 'delegatedAccount'.'numCheckpoints' allows us to see how many checkpoints a particular account has. 
  
  //Voting is done using 'checkpoints' from the past, and any time you vote, you call a function '_moveVotingPower' in the backend, which in turns writes these checkpoints.
}


export default deployGovernanceToken;

/*

Deployed the contract GovernanceToken at 0x5FbDB2315678afecb367f032d93F642f64180aa3
Checkpoints: 1
Delegated!

*/