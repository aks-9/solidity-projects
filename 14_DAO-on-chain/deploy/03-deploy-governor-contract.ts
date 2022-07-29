import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

import {
  QUORUM_PERCENTAGE,
  VOTING_PERIOD,
  VOTING_DELAY,
} from "../helper-hardhat-config"; //To be used as arguments while deploying the 'GovernorContract'.

const deployGovernorContract: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {

  // @ts-ignore
  const { getNamedAccounts, deployments, network } = hre;
  const { deploy, log, get } = deployments; //also importing the 'get' function from 'deployments'.

  const { deployer } = await getNamedAccounts();

  //Before deploying the 'GovernorContract', we need 'governanceToken' and 'timeLock' contracts, as their addresses will be passed to 'GovernorContract' while deploying it. 
  
  // So we use 'get' function to get those deployed contracts.
  const governanceToken = await get("GovernanceToken");
  const timeLock = await get("TimeLock");

  log("----------------------------------------------------");

  log("Deploying GovernorContract...");

  const governorContract = await deploy("GovernorContract", {
    from: deployer,
    args: [
      governanceToken.address,//passing the address of 'governanceToken' contract
      timeLock.address, //passing the address of 'timeLock' contract
      QUORUM_PERCENTAGE,
      VOTING_PERIOD,
      VOTING_DELAY,
    ],
    log: true,
    
  });

  log(`GovernorContract at ${governorContract.address}`);

}

export default deployGovernorContract;

/*
npx hardhat deploy

Nothing to compile
No need to generate any newer typings.
Deploying GovernanceToken...
deploying "GovernanceToken" (tx: 0x37a24916bdb2902840b9b7f48a3e6e81a326dfd2bdd946167d2f1429af76c251)...: deployed at 0x5FbDB2315678afecb367f032d93F642f64180aa3 with 1794473 gas
Deployed the contract GovernanceToken at 0x5FbDB2315678afecb367f032d93F642f64180aa3
Checkpoints: 1
Delegated!
Deploying deployTimeLock...
deploying "TimeLock" (tx: 0x40f989a22dc7ee635ea1a4a4c195d02a0ee29df61a0bc21030002adbd8a2b5d1)...: deployed at 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 with 1888453 gas
----------------------------------------------------
Deploying GovernorContract...
deploying "GovernorContract" (tx: 0x19f63fa83006cd9f98f3a362674640c7e1e3d6780f56a370cd87a021a3efa738)...: deployed at 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9 with 3585039 gas
GovernorContract at 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9
*/