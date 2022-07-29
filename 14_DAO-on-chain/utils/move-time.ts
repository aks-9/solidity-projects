import { network } from "hardhat";

export async function moveTime(amount: number) {
  console.log("Moving blocks...");
  await network.provider.send("evm_increaseTime", [amount]); //calling the method 'evm_increaseTime', so we can overcome the 'MIN_DELAY'.

  console.log(`Moved forward in time ${amount} seconds`);
}
