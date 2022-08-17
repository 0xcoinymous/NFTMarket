// this contract is for NFT market
// author : Abolfazl Iraninasab

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract NFTMarket is ReentrancyGuard, Context {
    using Counters for Counters.Counter;

    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    address private owner;
    uint256 private listingPrice = 0.01 ether;

    constructor() {
        owner = payable(_msgSender());
    }

    struct MarketItem {
        uint256 itemId;
        uint256 tokenId;
        uint256 price;
        address NFTContract;
        address payable seller;
        address payable owner;
        string itemName;
        string itemDescription;
        string tokenURI;
        bool sold;
    }

    event MarketItemCreated(
        uint256 indexed itemId,
        address indexed NFTContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    mapping(uint256 => MarketItem) private marketItems;

    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function getItems(uint256 id) public view returns (MarketItem memory) {
        return marketItems[id];
    }

    function listItemInMarket(
        address NFTContract,
        uint256 tokenId,
        uint256 price,
        string memory name,
        string memory description,
        string memory tokenURI
    ) public payable nonReentrant {                                                  // protected against reentrancy attacks
        require(price > 0, "price must be greater than 0! ");
        require(msg.value == listingPrice, "Please pay the listing price! ");

        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        marketItems[itemId] = MarketItem(
            itemId,
            tokenId,
            price,
            NFTContract,
            payable(_msgSender()),
            payable(address(0)),
            name,
            description,
            tokenURI,
            false
        );

        IERC721(NFTContract).transferFrom(_msgSender(), address(this), tokenId);

        emit MarketItemCreated(
            itemId,
            NFTContract,
            tokenId,
            _msgSender(),
            address(0),
            price,
            false
        );
    }

    function sellItem(address NFTContract, uint256 itemId) public payable nonReentrant {       // protected against reentrancy attacks
        uint256 price = marketItems[itemId].price;
        uint256 tokenId = marketItems[itemId].tokenId;

        require(msg.value == price, "Incorrect payment! ");

        require( _msgSender() != marketItems[itemId].seller,"you can't buy your own NFT ! ");

        Address.sendValue(marketItems[itemId].seller, msg.value);
        IERC721(NFTContract).transferFrom(address(this), _msgSender(), tokenId);

        marketItems[itemId].owner = payable(_msgSender());
        marketItems[itemId].seller = payable(_msgSender());

        marketItems[itemId].sold = true;
        _itemsSold.increment();
        Address.sendValue(payable(owner), listingPrice);
    }

    function showMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemCount = _itemIds.current();
        uint256 unsoldItems = itemCount - _itemsSold.current();
        uint256 currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItems);

        for (uint256 i = 0; i < itemCount; i++) {
            if (marketItems[i + 1].owner == address(0)) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = marketItems[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function showUserItems() public view returns (MarketItem[] memory) {
        uint256 itemCount = _itemIds.current();
        uint256 unsoldItems = itemCount - _itemsSold.current();
        uint256 currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItems);

        for (uint256 i = 0; i < itemCount; i++) {
            if (marketItems[i + 1].owner == _msgSender() || marketItems[i + 1].seller == _msgSender() ) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = marketItems[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

}

// finished 
