// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721Tradable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

interface IProxyOpenSea {
    function registry() external view returns (address);
}

contract Erc721TemplateV2 is ERC721Tradable {
    using SafeMath for uint256;
    using Address for address;

    mapping(uint256 => uint256) public tradeCount;
    mapping(address => uint) public openSeaAddress;

    constructor(
        address[] memory _listOpenSeaAddresses,
        address _proxyRegistryAddress,
        string memory _name,
        string memory _symbol
    )
    ERC721Tradable(_name, _symbol, _proxyRegistryAddress) {
        _changeStatusOpenSeaAddress(_listOpenSeaAddresses, 1);
    }

    function baseTokenURI() public pure override returns (string memory) {
        return "https://opensea-creatures-api.herokuapp.com/api/creature/";
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override {
        super._beforeTokenTransfer(from, to, tokenId);
        address sender = msg.sender;
        if (sender.isContract()) {
            try IProxyOpenSea(sender).registry() returns (address _res) {
                if (openSeaAddress[_res] == 1) {
                    tradeCount[tokenId] = tradeCount[tokenId].add(1);
                }
            } catch (bytes memory _err) {}
        }
    }

    function addOpenSeaAddress(address[] memory listAddresses) public onlyOwner {
        _changeStatusOpenSeaAddress(listAddresses, 1);
    }

    function removeOpenSeaAddress(address[] memory listAddresses) public onlyOwner {
        _changeStatusOpenSeaAddress(listAddresses, 0);
    }

    function _changeStatusOpenSeaAddress(address[] memory listAddresses, uint256 status) private {
        for (uint i = 0; i < listAddresses.length; i++) {
            openSeaAddress[listAddresses[i]] = status;
        }
    }

    function checkAddressOpenSea(address _proxy) view public returns (bool) {
        // return openSeaAddress[_proxy] == 1;
        return true;
    }

}
