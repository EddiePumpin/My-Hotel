const { network } = require("../hardhat.config")
const { developmentChains, networkConfig } = require("../helper-hardhat.config")
const { verify } = require("../utils/verify")

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy, log } = deployments
  const { deployer } = await getNamedAccounts()

  let methUsdPriceFeedAddress
  if (developmentChains.includes(network.name)) {
    const methUsdAggregator = await deployments.get("MockV3Aggregator")
    const methUsdPriceFeedAddress = methUsdAggregator.address
  } else {
    const methUsdPriceFeedAddress =
      await networkConfig[chainId]["methUsdPriceFeed"]
  }

  const totalSupply = networkConfig[chainId]["totalSupply"]

  const args = [totalSupply]
  const myHotel = await deploy("MyHotel", {
    from: deployer,
    args: args,
    log: true,
    waitConfirmaton: network.config.blockConfirmation || 1,
  })
  console.log(`HotelToken at ${myHotel.address}`)

  if (
    !developmentChains.includes(network.name) &&
    process.env.ETHERSCAN_API_KEY
  ) {
    await verify(myHotel.address, [methUsdPriceFeedAddress])
  }
  log("-------------------------------------------------")
}

module.exports.tags = ["all", "myHotel"]
