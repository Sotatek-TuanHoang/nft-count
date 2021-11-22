require("dotenv").config();
const { deployments, ethers, artifacts } = require("hardhat");

const func = async function ({ deployments, getNamedAccounts, getChainId }) {
  const { deploy, execute } = deployments;
  const { deployer } = await getNamedAccounts();

  console.log( {deployer} );

  const treasury = await deploy("Erc721Template", {
    from: deployer,
    args: [[deployer], "NFT", "NFT", deployer],
    log: true,
  });

  await hre.run('verify:verify', {
    address: treasury.address,
    constructorArguments: [[deployer], "NFT", "NFT", deployer],
  })
};

module.exports = func;

module.exports.tags = ['deploy-verify'];
