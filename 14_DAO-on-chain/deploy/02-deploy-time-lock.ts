import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { MIN_DELAY } from "../helper-hardhat-config";

const deployTimeLock: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {

  // @ts-ignore
  const { getNamedAccounts, deployments } = hre; 

  const { deploy, log } = deployments; 

  const { deployer } = await getNamedAccounts(); 

  log("Deploying deployTimeLock...");

  const timeLock = await deploy("TimeLock", {
    from: deployer,
    args: [MIN_DELAY, [], [] ],// passing arguments for contract, leaving the 'proposers' and 'executors' empty as of now.
    log: true,

  })

};

export default deployTimeLock;

/*
Deploying GovernanceToken...
deploying "GovernanceToken" (tx: 0x14f2d025378ac7d2109d16a5c511d9bf82b7b6322a6e22c3b039870238a1a895)...: deployed at 0x5FbDB2315678afecb367f032d93F642f64180aa3 with 3326235 gas
Deployed the contract GovernanceToken at 0x5FbDB2315678afecb367f032d93F642f64180aa3
Checkpoints: 1
Delegated!
Deploying deployTimeLock...
deploying "TimeLock" (tx: 0x90ba96b651067c6963ea461bcd0c6aef234006d2df80f63380fd64319ab48f1c)...: deployed at 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 with 3054354 gas

*/