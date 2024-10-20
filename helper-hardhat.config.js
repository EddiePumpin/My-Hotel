const { ethers } = require("hardhat")

const networkConfig = {
  11155111: {
    name: "sepolia",
    ethUsdPriceFeed: "0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc7cb1", // Base ETH price feed
    totalSupply: "10000000000", // 10B
    hotelTokenAddress: "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512",
  },

  31337: {
    name: "hardhat",
    ethUsdPriceFeed: "0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc7cb1", // Base ETH price feed
    totalSupply: "10000000000", // 10B
    hotelTokenAddress: "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512",
  },
}
const INITIAL_SUPPLY = ethers.parseEther("50000000")
const DECIMALS = 8
const developmentChains = ["hardhat", "localhost"] // We are going to only want to deploy mocks if we are on a development chain. Localhost  is the local network for hardhat.

module.exports = {
  networkConfig,
  developmentChains,
  DECIMALS,
  INITIAL_SUPPLY,
}
