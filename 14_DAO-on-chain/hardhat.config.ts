import "@typechain/hardhat";
import "@nomiclabs/hardhat-ethers";
import "hardhat-deploy";

import { HardhatUserConfig } from "hardhat/config";

// /** @type import('hardhat/config').HardhatUserConfig */
// module.exports = {
//   solidity: "0.8.9",
// };


const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: { //for tests
      chainId: 31337
    },
    localhost: { // when you run npx hardhat node
      chainId: 31337
    },
  },
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  namedAccounts: {
    deployer: {
      default: 0, // zeroth account will be used as the deployer, i.e the first account. 
    },
  },
};

export default config;
