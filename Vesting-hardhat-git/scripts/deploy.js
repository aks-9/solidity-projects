const hre = require("hardhat");

async function main() {
  
  // Token contract
  const Token = await hre.ethers.getContractFactory("Token");
  const token = await Token.deploy();

  await token.deployed();

  console.log("Token deployed to:", token.address);


  // Vesting contract
  const Vesting = await hre.ethers.getContractFactory("Vesting");
  const vesting = await Vesting.deploy("Mentor's address ","Advisor address","Partner address","Startime");// need to pass Mentor's, Advisor's, and Partner's addresses in deploy function. Also, a Startime unix timestamp to the constructor.

  await vesting.deployed();

  console.log("Token deployed to:", vesting.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
