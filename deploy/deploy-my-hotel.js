const { network } = require("../hardhat.config")
const { developmentChains, networkConfig } = require("../helper-hardhat.config")
const { verify } = require("../utils/verify")

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy, log } = deployments
  const { deployer } = await getNamedAccounts()

const totalSupply = networkConfig[chainId]["totalSupply"]

const args = [totalSupply]  
const myHotel = awiat deploy("MyHotel", {
  from: deployer,
  args: args,
  log: true,
  waitConfirmaton: network.config.blockConfirmation || 1,
})

if (
  !developmentChains.includes(network.name) &&
  process.env.ETHERSCAN_API_KEY
) {
  await verify(myHotel.address, [ethUsdPriceFeedAddress])
}
log("-------------------------------------------------")

}

module.exports.tags = ["all", "myHotel"]
