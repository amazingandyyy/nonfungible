//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract Marketplace is ReentrancyGuard, Ownable {

    using Counters for Counters.Counter;
    
    Counters.Counter private _itemIds;
    Counters.Counter private _itemSold; // total number of items sold
    mapping(address => uint) public userWallets;

    uint public fee = 0.025 ether; // only charge when sales are made

    struct ListingItem {
        uint itemId;
        address nftContract;
        uint tokenId;
        address payable seller;
        address payable owner; // initial to address(0), then new owner/buyder
        uint price;
        bool sold;
    }

    mapping(uint => ListingItem) private _listingItems;

    event ItemListed(
        uint itemId,
        address indexed nftContract,
        uint indexed tokenId,
        address payable seller,
        address payable owner,
        uint price,
        bool sold
    );
    
    event ItemSold(
        uint itemId,
        address indexed nftContract,
        uint indexed tokenId,
        address payable seller,
        address payable owner,
        uint price,
        bool sold
    );

    // function setFee(uint _price) public onlyOwner {
    //     fee = _price;
    // }

    function listItem(address nftContract, uint tokenId, uint price) public nonReentrant {
        uint _newItemId = _itemIds.current();
        _listingItems[_newItemId] = ListingItem(
            _newItemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );
        _itemIds.increment();

        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        emit ItemListed(
            _newItemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );
    }

    function buyItem(address nftContract, uint itemId) public payable nonReentrant {
        require(msg.value == _listingItems[itemId].price + fee, "Price does not match listing price");
        require(!_listingItems[itemId].sold, "Item is already sold");

        IERC721(nftContract).transferFrom(address(this), msg.sender, _listingItems[itemId].tokenId);

        // send price to the seller's wallet
        // take withdrawal pattern
        userWallets[_listingItems[itemId].seller] += (msg.value-fee);

        _listingItems[itemId].owner = payable(msg.sender);
        _listingItems[itemId].sold = true;
        _itemSold.increment();

        emit ItemSold(
            itemId,
            nftContract,
            _listingItems[itemId].tokenId,
            payable(_listingItems[itemId].seller),
            payable(msg.sender),
            _listingItems[itemId].price,
            true
        );
    }

    /// @notice user can withdraw from their wallet
    function withdraw() public {
        require(userWallets[msg.sender] > 0, "No money to withdraw");
        (bool sent,) = msg.sender.call{value: userWallets[msg.sender]}("");
        require(sent, "Failed to send Ether");
        userWallets[msg.sender] = 0;
    }

    /// @notice fetch all unsold items
    function fetchAllListingItems() public view returns (ListingItem[] memory) {
        ListingItem[] memory _items = new ListingItem[](_itemIds.current() - _itemSold.current());
        uint _itemCount = 0;
        for (uint i = 0; i < _itemIds.current(); i++) {
            if(!_listingItems[i].sold && _listingItems[i].owner == address(0)){
                _items[_itemCount] = _listingItems[i];
                _itemCount++;
            }
        }
        return _items;
    }

    /// @notice fetch items user bought
    function fetchUserBoughtItems() public view returns (ListingItem[] memory) {
        uint _userItemCount = 0;
        for (uint i = 0; i < _itemIds.current(); i++) {
            if(_listingItems[i].sold && _listingItems[i].owner == address(msg.sender)){
                _userItemCount++;
            }
        }

        uint _itemCount = 0;
        ListingItem[] memory _items = new ListingItem[](_userItemCount);
        for (uint i = 0; i < _itemIds.current(); i++) {
            if(_listingItems[i].sold && _listingItems[i].owner == address(msg.sender)){
                _items[_itemCount] = _listingItems[i];
                _itemCount++;
            }
        }

        return _items;
    }

    /// @notice fetch item user owns
    function fetchUserOwningItems() public view returns (ListingItem[] memory) {
        uint _userItemCount = 0;
        for (uint i = 0; i < _itemIds.current(); i++) {
            if(_listingItems[i].owner == address(msg.sender)){
                _userItemCount++;
            }
        }

        uint _itemCount = 0;
        ListingItem[] memory _items = new ListingItem[](_userItemCount);
        for (uint i = 0; i < _itemIds.current(); i++) {
            if(_listingItems[i].owner == address(msg.sender)){
                _items[_itemCount] = _listingItems[i];
                _itemCount++;
            }
        }

        return _items;
    }

    /// @notice fetch user's listing/unsold items
    function fetchUserListingItems() public view returns (ListingItem[] memory) {
        uint _userItemCount = 0;
        for (uint i = 0; i < _itemIds.current(); i++) {
            if(!_listingItems[i].sold && _listingItems[i].seller == address(msg.sender)){
                _userItemCount++;
            }
        }

        uint _itemCount = 0;
        ListingItem[] memory _items = new ListingItem[](_userItemCount);
        for (uint i = 0; i < _itemIds.current(); i++) {
            if(!_listingItems[i].sold && _listingItems[i].seller == address(msg.sender)){
                _items[_itemCount] = _listingItems[i];
                _itemCount++;
            }
        }

        return _items;
    }
}