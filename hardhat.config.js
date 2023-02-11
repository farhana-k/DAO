require("@nomicfoundation/hardhat-toolbox");


// Go to https://www.alchemyapi.io, sign up, create
// a new App in its dashboard, and replace "KEY" with its key
const ALCHEMY_API_KEY = "vHVjIYjksH6_OAWsVCtQO4iv0TWZMlOm";

// Replace this private key with your Goerli account private key
// To export your private key from Metamask, open Metamask and
// go to Account Details > Export Private Key
// Beware: NEVER put real Ether into testing accounts
const GOERLI_PRIVATE_KEY = "e0fbfdd7e0eef56be5178c94cd3b0dcc0e9ef52e0cebe44e17ad739b853713cd";

module.exports = {
  solidity: "0.8.0",
  networks: {
    goerli: {
      // url: `https://eth-goerli.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
      url: `https://eth-goerli.g.alchemy.com/v2/vHVjIYjksH6_OAWsVCtQO4iv0TWZMlOm`,
      accounts: [GOERLI_PRIVATE_KEY]
    }
  }
};

// /** @type import('hardhat/config').HardhatUserConfig */
// module.exports = {
//   solidity: "0.8.0",
// };
