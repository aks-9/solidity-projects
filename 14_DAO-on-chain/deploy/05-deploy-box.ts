//This will deploy the contract to be governed by the DAO.

import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

// @ts-ignore
import { ethers } from "hardhat";

const deployBox: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {

  // @ts-ignore
  const { getNamedAccounts, deployments, network } = hre;
  const { deploy, log, get } = deployments;

  const { deployer } = await getNamedAccounts();

  log("----------------------------------------------------");
  log("Deploying Box...");

  //This is only 'Box' deployment object, it doesn't give an instance of 'Box' contract. It doesn't have contract functions.
  const box = await deploy("Box", {
    from: deployer,
    args: [],
    log: true,
  });
  // Now the 'deployer' account is used for deploying the 'Box' contract, so the ownership needs to be transferred to the 'TimeLock' contract.

  log(`Box at ${box.address}`);

  const boxContract = await ethers.getContractAt("Box", box.address);// Getting an instance of 'Box' contract, or getting a 'Box' contract object with all the functions.

  const timeLock = await ethers.getContract("TimeLock"); // Getting an instance of 'TimeLock' contract.

  const transferTx = await boxContract.transferOwnership(timeLock.address); //Transferring the ownership of the 'Box' contract to the 'TimeLock' contract.

  log("----------------------------------------------------");
  log("Ownership has been transferred to the TimeLock!");

  await transferTx.wait(1);
};

export default deployBox;

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
----------------------------------------------------
Setting up contracts for roles...
----------------------------------------------------
Deploying Box...
deploying "Box" (tx: 0x30f0fd3ccf8f37f14104fe38acb42e5105ec9a329b5d823021304911411defdc)...: deployed at 0xa513E6E4b8f2a923D98304ec87F64353C4D5C853 with 229444 gas
Box at 0xa513E6E4b8f2a923D98304ec87F64353C4D5C853
----------------------------------------------------
Ownership has been transferred to the TimeLock!

*/