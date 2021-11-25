const Erc721Template = artifacts.require('Erc721TemplateV2');
const { default: BigNumber } = require('bignumber.js');
const { assert } = require('chai');
const { ethers, waffle } = require('hardhat');

const BN = web3.utils.BN;
const {
  etherUnsigned
} = require('./Ethereum');

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bn')(BN))
  .should();

const registryProxy = "0x185728DdB1cb2c503733a1a1D5B869D7821948B0";

contract('Erc721Template Contract', function (accounts) {
  it('check mint function', async () => {
    const token = await Erc721Template.new([registryProxy], registryProxy, "NFT", "NFT");
    const rs = await token.mintTo(accounts[0]);
    expectThrow(token.mintTo(accounts[1], {from: accounts[1]}), "Ownable: caller is not the owner");
  });

  it('check add proxy', async () => {
    const token = await Erc721Template.new([registryProxy], registryProxy, "NFT", "NFT");
    await token.addOpenSeaAddress([accounts[0], accounts[1]]);
    expectThrow(token.addOpenSeaAddress([accounts[0], accounts[1]], {from: accounts[1]}), "Ownable: caller is not the owner");
    await token.removeOpenSeaAddress([accounts[0], accounts[1]]);
    expectThrow(token.removeOpenSeaAddress([accounts[0], accounts[1]], {from: accounts[1]}), "Ownable: caller is not the owner");
  });

});

function assertEqual (val1, val2, errorStr) {
  val2 = val2.toString();
  val1 = val1.toString()
  assert(new BN(val1).should.be.a.bignumber.that.equals(new BN(val2)), errorStr);
}

function expectError(message, messageCompare) {
  messageCompare = "Error: VM Exception while processing transaction: revert " + messageCompare;
  assert(message, messageCompare);
}

async function expectThrow(f1, messageCompare) {
  try {
    await f1;
  } catch (e) {
    expectError(e.toString(), messageCompare)
  }; 
}

async function increaseTime(second) {
  await ethers.provider.send('evm_increaseTime', [second]); 
  await ethers.provider.send('evm_mine');
}
