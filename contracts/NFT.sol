//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

contract NFT is ERC721URIStorage {
  using Counters for Counters.Counter;

  Counters.Counter private tokenIds;

  address internal contractAddress;
  constructor(address marketplaceAddress) ERC721("NonFungibleItem", "NFI") {
    contractAddress = address(marketplaceAddress);
  }

  /// @notice create a new item
  /// @param tokenURI: token URI
  function createItem(string memory tokenURI) public returns (uint) {
    uint itemId = tokenIds.current();
    tokenIds.increment();
    _mint(msg.sender, itemId);
    _setTokenURI(itemId, tokenURI);
    setApprovalForAll(contractAddress, true); // from ERC721.sol
    return itemId;
  }
}
