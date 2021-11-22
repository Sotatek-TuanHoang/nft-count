// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./common/meta-transactions/ContentMixin.sol";
import "./common/meta-transactions/NativeMetaTransaction.sol";

contract OwnableDelegateProxy {}

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

contract Erc721Template is ContextMixin, ERC721Enumerable, NativeMetaTransaction, Ownable {
    using SafeMath for uint256;

    mapping(uint256 => uint256) public tradeCount;
    mapping(address => uint) public openSeaAddress;
    address proxyRegistryAddress;
    uint256 private _currentTokenId = 0;

    constructor(address[] memory _listOpenSeaAddresses, string memory _name, string memory _symbol, address _proxyRegistryAddress) ERC721(_name, _symbol) {
        proxyRegistryAddress = _proxyRegistryAddress;
        _initializeEIP712(_name);
        _changeStatusOpenSeaAddress(_listOpenSeaAddresses, 1);
    }

    function mintTo(address _to) public onlyOwner {
        uint256 newTokenId = _getNextTokenId();
        _mint(_to, newTokenId);
        _incrementTokenId();
    }

    /**
     * @dev calculates the next token ID based on value of _currentTokenId
     * @return uint256 for the next token ID
     */
    function _getNextTokenId() private view returns (uint256) {
        return _currentTokenId.add(1);
    }

    /**
     * @dev increments the value of _currentTokenId
     */
    function _incrementTokenId() private {
        _currentTokenId++;
    }

    /**
     * Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.
     */
    function isApprovedForAll(address owner, address operator)
        override
        public
        view
        returns (bool)
    {
        // Whitelist OpenSea proxy contract for easy trading.
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(owner)) == operator) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }

    /**
     * This is used instead of msg.sender as transactions won't be sent by the original token owner, but by OpenSea.
     */
    function _msgSender()
        internal
        override
        view
        returns (address sender)
    {
        return ContextMixin.msgSender();
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override {
        super._beforeTokenTransfer(from, to, tokenId);
        if (openSeaAddress[from] == 1) {
            tradeCount[tokenId] = tradeCount[tokenId].add(1);
        }
    }

    function addOpenSeaAddress(address[] memory listAddresses) public onlyOwner {
        _changeStatusOpenSeaAddress(listAddresses, 1);
    }

    function removeOpenSeaAddress(address[] memory listAddresses) public onlyOwner {
        _changeStatusOpenSeaAddress(listAddresses, 0);
    }

    function _changeStatusOpenSeaAddress(address[] memory listAddresses, uint256 status) private {
        for (uint i = 0; i <= listAddresses.length; i++) {
            openSeaAddress[listAddresses[i]] = status;
        }
    }

}
