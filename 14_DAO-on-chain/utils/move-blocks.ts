import { network } from "hardhat";

//amount is the number of blocks we want to move.
export async function moveBlocks(amount: number) {

  console.log("Moving blocks...");

  for (let index = 0; index < amount; index++) {

    //calling the method 'evm_mine', so basically we're mining the blocks faster.
    await network.provider.request({
      method: "evm_mine",
      params: [],
    });

  }
  
  console.log(`Moved ${amount} blocks`);
}
