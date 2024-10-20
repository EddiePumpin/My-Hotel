const { network } = require("hardhat")
const {
  developmentChains,
  DECIMALS,
  INITIAL_SUPPLY,
} = require("../helper-hardhat.config")

module.exports = async ({ getNameAccounts, deployments }) => {
  const { deploy, log } = deployments
  const { deployer } = await getNamedAccounts()
  const chainId = network.config.chainId

  if (developmentChains.includes(network.name)) {
    log("Local network detected! Deploying mocks...")
    await deploy("MockV3Aggregator", {
      contract: "MockV3Aggregator",
      from: deployer,
      logs: true,
      args: [DECIMALS, INITIAL_SUPPLY],
    })
    log("Mocks deployed!")
    log("-----------------------------------------")
  }
}

module.exports.tags = ["all", "mocks"]
