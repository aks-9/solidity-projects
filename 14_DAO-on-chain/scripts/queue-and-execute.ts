//* In order to queue and execute a proposal, we have call the 'queue' function from 'GovernorTimelockControl.sol' contract, which we have inherited in our GovernorContract. It has exact same arguments as of 'propose' function.

 /* 
    The 'queue' function has the following arguments:

    function queue(
        address[] memory targets, //* The addresses of the smart contracts to be called.
        uint256[] memory values,  //* The amount of Ether sent with this transaction.
        bytes[] memory calldatas, //* The 'encoded' parameters for the functions we want to call.
        bytes32 descriptionHash //* To mention the reason of the proposal.
    ) public virtual override returns (uint256) {}
*/

// @ts-ignore
import { ethers, network } from "hardhat";

import {
  FUNC,
  NEW_STORE_VALUE,
  PROPOSAL_DESCRIPTION,
  MIN_DELAY,
  developmentChains,
} from "../helper-hardhat-config";

import { moveBlocks } from "../utils/move-blocks";
import { moveTime } from "../utils/move-time"; //

export async function queueAndExecute() {

  const args = [NEW_STORE_VALUE];
  const functionToCall = FUNC;

  const box = await ethers.getContract("Box");

  const encodedFunctionCall = box.interface.encodeFunctionData(functionToCall, args);//creating 'encoded' parameters for functions that we want to call on Box contract. This will turn it into bytes calldata. It has two arguments: 'functionToCall' and 'args', so we will include them in our 'queue' function's argument.

  //* With our 'propose' function, when we passed 'proposalDescription', it gets hashed on-chain. And that's why our 'queue' function will be looking for a 'descriptionHash'. It will be a little cheaper gas-wise as well.

  const descriptionHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(PROPOSAL_DESCRIPTION));
  // could also use ethers.utils.id(PROPOSAL_DESCRIPTION)

  //* QUEUING
  const governor = await ethers.getContract("GovernorContract");
  console.log("Queueing...");

  const queueTx = await governor.queue([box.address], [0], [encodedFunctionCall], descriptionHash); // Calling the 'queue' function.

  await queueTx.wait(1);

  if (developmentChains.includes(network.name)) {
    await moveTime(MIN_DELAY + 1); //we have to create a new file called 'move-time.ts' in the 'utils' folder. This will help us speed up the time, so that while testing on the localhost, we don't have to wait 'MIN_DELAY' after a proposal is queued.
    await moveBlocks(1);
  }

  //* EXECUTING
  console.log("Executing...");
  // this will fail on a testnet because you need to wait for the MIN_DELAY!

  const executeTx = await governor.execute(
    [box.address],
    [0],
    [encodedFunctionCall],
    descriptionHash
  );
  await executeTx.wait(1);

  console.log(`Box value: ${await box.retrieve()}`); //CHECKING IF THE VALUE WAS UPDATED IN THE BOX CONTRACT OR NOT.
}

queueAndExecute()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })


/*
npx hardhat run scripts/queue-and-execute.ts --network localhost

Queueing...
Moving blocks...
Moved forward in time 3601 seconds
Moving blocks...
Moved 1 blocks
Executing...
Box value: 77

*/