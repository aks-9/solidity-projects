//* This creates a new proposal to store a new value ==77 in our 'Box' contract.

//* Once the proposing is done, we will vote on it.

//* And if it passes, then we will queue it for execution.

//* Finally, after minimum delay has passed, it will be executed.

// @ts-ignore
import { ethers, network } from "hardhat";
import {
  FUNC,  
  PROPOSAL_DESCRIPTION,
  NEW_STORE_VALUE,
  developmentChains, //for testing and speeding up
  VOTING_DELAY,
  proposalsFile,
} from "../helper-hardhat-config";
import { moveBlocks } from "../utils/move-blocks"; //importing for testing and speeding the blocks up.
import * as fs from "fs"; // will be used in reading and writing the proposals saved in json file.



export async function propose(args: any[], functionToCall: string, proposalDescription: string) {

  const governor = await ethers.getContract("GovernorContract"); //need this as we are creating a proposal on GovernorContract.
  const box = await ethers.getContract("Box"); // need Box contract, as we are proposing changes to Box contract.

  //Now in order to create a proposal, we will call the 'propose' function of 'Governor.sol', which we have inherited in our GovernorContract.

  /* 
    The 'propose' function has the following arguments:

    function propose(
        address[] memory targets, //* The addresses of the smart contracts to be called.
        uint256[] memory values,  //* The amount of Ether sent with this transaction.
        bytes[] memory calldatas, //* The 'encoded' parameters for the functions we want to call.
        string memory description //* To mention the reason of the proposal.
    ) public virtual override returns (uint256) {}
    */

  const encodedFunctionCall = box.interface.encodeFunctionData(
    functionToCall,
    args
  ); //creating 'encoded' parameters for functions that we want to call on Box contract. This will turn it into bytes calldata. It has two arguments: 'functionToCall' and 'args', so we will include them in our propose function's argument.

  // console.log(encodedFunctionCall);

  console.log(`Proposing ${functionToCall} on ${box.address} with ${args}`);
  console.log(`Proposal Description:\n  ${proposalDescription}`);


  //* CREATING THE PROPOSAL
  //Only the GovernorContract will propose
  const proposeTx = await governor.propose(
    [box.address], //target
    [0], //value
    [encodedFunctionCall], //calldata
    proposalDescription //description
  );

  const proposeReceipt = await proposeTx.wait(1); //as propose function emits an event which has 'proposalId', we also need to have it.

  //* Now since we have a Voting Delay, people can't really vote till voting delay has passed after creating a proposal. But for testing purposes, in the local blockchain, we can speed up things by moving the blocks.

   // If working on a development chain, we will push the blocks forward till we get to the voting period. The 'network' is coming from 'ethers'. We will now create a new folder called 'utils', and in it we will have our 'moveBlocks.ts' file.
   if (developmentChains.includes(network.name)) {
    await moveBlocks(VOTING_DELAY + 1); //calling the 'moveBlocks' that we had imported. Moving the blocks so that voting delay has passed, 'voting delay + 1' ensures that.
  }

  
  const proposalId = proposeReceipt.events[0].args.proposalId; //getting the proposal ID from the first emitted event. It is in the arguments of the event. Also we need to save this 'proposalId' so that our other scripts like 'vote' and 'queue-and-execute' know what the 'proposalId' when we run them. So we will create a new file called 'proposals.json', which will store all our proposals and their IDs. Write the chain Ids in 'proposals.json' like {"31337": []}. Set it in the 'helper-hardhat-config.ts' file, and then import it here.

  let proposals = JSON.parse(fs.readFileSync(proposalsFile, "utf8")); // reading all the proposals using 'fs' module and 'proposalsFile' we have imported.

  proposals[network.config.chainId!.toString()].push(proposalId.toString()); //saving the proposals by their chain IDs. '!' indicates that there will be a 'chainId' for sure. Then pushing the 'proposalId'.

  fs.writeFileSync(proposalsFile, JSON.stringify(proposals)); //Writing to the proposals file.
}

propose([NEW_STORE_VALUE], FUNC, PROPOSAL_DESCRIPTION)
  .then(() => process.exit(0))
  .catch((error) => {
    console.log(error);
    process.exit(1);
  });

/*
Run a hardhat node first:
npx hardhat node

Then to run this 'propose' script in a new terminal:

npx hardhat run scripts/propose.ts --network localhost
0x6057361d000000000000000000000000000000000000000000000000000000000000004d //encoded bytes
*/

/*
When propose script is finished, Run a hardhat node first:
npx hardhat node

Then to run this 'propose' script in a new terminal:

npx hardhat run scripts/propose.ts --network localhost

Proposing store on 0xa513E6E4b8f2a923D98304ec87F64353C4D5C853 with 77
Proposal Description:       
  Proposal #1 77 in the Box!
Moving blocks...
Moved 2 blocks

W've successfully moved the blocks and stored our value! You can check the proposal Id in the 'proposal.json' file.


*/