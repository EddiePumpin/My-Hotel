const { network } = require("hardhat")
const { developmentChains, networkConfig } = require("../helper-hardhat.config")
const { verify } = require("../utils/verify")

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy, log } = deployments
  const { deployer } = await getNamedAccounts()
  const chainId = network.config.chainId

  let ethUsdPriceFeedAddress
  log("----------------------------------------------------------------")
  if (developmentChains.includes(network.name)) {
    const ethUsdAggregator = await deployments.get("MockV3Aggregator")
    ethUsdPriceFeedAddress = ethUsdAggregator.address
  } else {
    const ethUsdPriceFeedAddress =
      await networkConfig[chainId]["ethUsdPriceFeed"]
  }

  let hotelTokenAddress
  if (developmentChains.includes(network.name)) {
    const hotelToken = await deployments.get("MegaERC20")
    hotelTokenAddress = hotelToken.address
  } else {
    hotelTokenAddress = networkConfig[chainId]["hotelTokenAddress"]
  }

  // const _hotelTokenAddress = methERC20.address
  // const _hotelTokenAddress = networkConfig[chainId]["hotelTokenAddress"]
  const totalSupply = networkConfig[chainId]["totalSupply"]

  const args = [hotelTokenAddress, totalSupply]

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
    await verify(myHotel.address, [])
  }
  log("-------------------------------------------------")
}

module.exports.tags = ["all", "myHotel"]
