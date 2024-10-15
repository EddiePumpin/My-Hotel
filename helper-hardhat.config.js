const { ethers } = require("hardhat")

const networkConfig = {
    11155111: {
        name: "sepolia",
        methUsdPriceFeed: "0x",
        totalSupply: "10000000000", // 10B
    },

    31337: {
        name: "hardhat",
    },
}
const INITIAL_SUPPLY = ethers.parseEther("50000000")

const developmentChains = ["hardhat", "localhost"] // We are going to only want to deploy mocks if we are on a development chain. Localhost  is the local network for hardhat.

module.exports = {
    networkConfig,
    developmentChains,
    INITIAL_SUPPLY,
}
