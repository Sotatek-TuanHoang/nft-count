require("dotenv").config();
const { deployments, ethers, artifacts } = require("hardhat");

const func = async function ({ deployments, getNamedAccounts, getChainId }) {
  const { deploy, execute } = deployments;
  const { deployer } = await getNamedAccounts();

  console.log( {deployer} );

  const registryProxy = process.env.REGISTRY;
  const openSea = [process.env.REGISTRY];
  const name = process.env.NAME;
  const symbol = process.env.SYMBOL;

  // const erc721Template = await deploy("Erc721Template", {
  //   from: deployer,
  //   args: [openSea, "NFT Count", "NFT", registryProxy],
  //   log: true,
  // });
  
  const erc721Template = await deploy("Erc721TemplateV2", {
    from: deployer,
    args: [openSea, registryProxy, name, symbol],
    log: true,
  });

  await sleep(30000);

  await hre.run('verify:verify', {
    address: erc721Template.address,
    constructorArguments: [openSea, registryProxy, name, symbol],
  })
};

module.exports = func;

module.exports.tags = ['deploy-verify'];


async function sleep(timeout) {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      resolve();
    }, timeout);
  });
}