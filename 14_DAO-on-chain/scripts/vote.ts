import * as fs from "fs";
// @ts-ignore
import { network, ethers } from "hardhat";
import { proposalsFile, developmentChains, VOTING_PERIOD } from "../helper-hardhat-config";
import { moveBlocks } from "../utils/move-blocks";

const index = 0;// for passing to main function as argument. '0' is the first index in the proposals array.

//we're calling this 'main' because it is a bit different from our 'propose' script.
async function main(proposalIndex: number) {

  const proposals = JSON.parse(fs.readFileSync(proposalsFile, "utf8"));// reading proposals file.
  // You could swap this out for the ID you want to use too

  const proposalId = proposals[network.config.chainId!][proposalIndex]; //gettting the specific proposal at a specific ID. In this case the first one, the zeroth one.


  //Voting works this way in this example--> 0 = Against, 1 = For, 2 = Abstain
  const voteWay = 1; //so we're voting in favour of proposal.

  const reason = "I lika to vote and participate";
  
  const governor = await ethers.getContract("GovernorContract");// need governor contract to do voting.

  const voteTx = await governor.castVoteWithReason(proposalId, voteWay, reason); //using 'castVoteWithReason' method from 'IGovernor.sol' which we've imported in our GovernorContract.
  await voteTx.wait(1);

  if (developmentChains.includes(network.name)) {
    await moveBlocks(VOTING_PERIOD + 1); //calling the 'moveBlocks' that we had imported. Moving the blocks so that voting period has passed, 'voting period + 1' ensures that.
  }
}
console.log("Voted!");


main(index)
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })

/*
--> Make sure the same node was running when you created the proposal, otherwise it will throw gas estimation error due to unknown proposal ID.


npx hardhat run scripts/vote.ts --network localhost
Voted!
Moving blocks...
Moved 6 blocks
*/