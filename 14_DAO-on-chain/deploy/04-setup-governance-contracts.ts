// As we had left the 'proposers' and 'executors' empty  while deploying the 'TimeLock' contract. 

// Now We want the only allow the 'GovernorContract' to be the 'proposer'. The 'GovernorContract' is the only one that could propose to the 'TimeLock' contract. And then anybody should be able to execute it.

// So Everybody votes, then the 'GovernanceContract' proposes to the 'TimeLock', once it's in the 'TimeLock', it waits minimum delay period, then anybody can go ahead and execute it. We will setup the roles like this only.


import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

import { ADDRESS_ZERO } from "../helper-hardhat-config"; //To be used in roles.

// @ts-ignore
import { ethers } from "hardhat";

const setupContracts: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {

  // @ts-ignore
  const { getNamedAccounts, deployments, network } = hre;
  const { deploy, log, get } = deployments;

  const { deployer } = await getNamedAccounts();

  const timeLock = await ethers.getContract("TimeLock", deployer); //Using 'ethers' to call 'getContract' method on 'TimeLock', and attaching it to the 'deployer' account. So everytime we call a function of 'TimeLock' contract, it will be the called through the 'deployer' account.

  const governor = await ethers.getContract("GovernorContract", deployer); //Similarly attaching deployer account to 'GovernorContract'

  log("----------------------------------------------------")
  log("Setting up contracts for roles...")

  //The way this works, is that we need to get the bytecodes of the different roles, mentioned in the 'TimeLockController' inherited by our 'TimeLock' contract.

  const proposerRole = await timeLock.PROPOSER_ROLE();
  const executorRole = await timeLock.EXECUTOR_ROLE();
  const adminRole = await timeLock.TIMELOCK_ADMIN_ROLE();

  //Granting the proposer role to our 'governor' contract attached to 'deployer' account.
  const proposerTx = await timeLock.grantRole(proposerRole, governor.address);
  await proposerTx.wait(1);

  //Granting the executor role to nobody in particular, which means everybody can execute it.
  const executorTx = await timeLock.grantRole(executorRole, ADDRESS_ZERO);
  await executorTx.wait(1);

  //Right now, our deployer account owns the 'TimeLock' contract. Now that we've given decentralized access to roles, we need to revoke it. 
  const revokeTx = await timeLock.revokeRole(adminRole, deployer);
  await revokeTx.wait(1);

  // Now nobody owns the 'TimeLock' and any thing that needs to be done by 'TimeLock' will  have to go through voting via 'GovernorContract'.'
};

export default setupContracts;