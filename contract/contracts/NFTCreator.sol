// this contract is for creating NFT's
// author : Abolfazl Iraninasab

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTCreator is ERC721URIStorage{

    using Counters for Counters.Counter;

    Counters.Counter private _tokenid;

    address private NFTMarketAdr;

    event Mint(address owner, uint256 TokenID);

    constructor(address NFTMarketAddress) ERC721("Abolfazl","ABL"){
        NFTMarketAdr = NFTMarketAddress;
    }

    function createToken(string memory tokenURI) public returns (uint256){

        _tokenid.increment();
        uint256 newTokenID = _tokenid.current();

        _mint(_msgSender(), newTokenID);
        _setTokenURI(newTokenID, tokenURI);
        setApprovalForAll(NFTMarketAdr, true);
        emit Mint(_msgSender(), newTokenID);

        return newTokenID;

    }

}