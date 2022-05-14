// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "erc721a/contracts/extensions/ERC721AQueryable.sol";

contract NFT is ERC721AQueryable, Ownable, ReentrancyGuard {
    using Strings for uint256;

    string private baseTokenURI;
    string private hiddenTokenURI;

    uint256 maxNfts = 10000;
    uint256 price = 85 ether;
    uint256 maxNftsPerTx = 5;
    uint256 nftsLimitPerAddress = 10;

    bool public paused = false;
    bool public presale = false;
    bool public revealed = false;

    mapping(address => uint256) nftsMintedBalance;
    mapping(address => bool) whitelistedAddresses;

    // constructor
    constructor(string memory _baseTokenUri, string memory _hiddenTokenUri)
        ERC721A("Crypto Manga Club", "CMC")
    {
        setBaseTokenURI(_baseTokenUri);
        setHiddenURI(_hiddenTokenUri);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function _mintNfts(address _receiver, uint256 _mintAmount) internal {
        _safeMint(_receiver, _mintAmount);

        nftsMintedBalance[msg.sender] =
            nftsMintedBalance[msg.sender] +
            _mintAmount;
    }

    function mint(uint256 _mintAmount)
        public
        payable
        nonReentrant
        isPresale(msg.sender)
        isPaused
        mintCompliance(_mintAmount, msg.sender)
    {
        require(
            price * _mintAmount >= msg.value,
            "Insufficient funds to mint !!"
        );
        _mintNfts(msg.sender, _mintAmount);
    }

    function giftNfts(address _reciever, _mintAmount) public onlyOwner {
        require(
            totalSupply() + _mintAmount <= maxNfts,
            "All  Nfts are solded out !!"
        );
        _safeMint(_reciever, _mintAmount);
    }

    modifier isPaused() {
        require(!paused, "Contract is paused right now !!");
        _;
    }

    modifier isPresale(address _user) {
        if (presale) {
            require(
                whitelistedAddresses[_user] == true,
                "You are not whitelisted to Mint !!"
            );
        }
        _;
    }

    modifier mintCompliance(uint256 _mintAmount, address _user) {
        require(_mintAmount > 0, "You have to mint atleast 1 Nft !!");
        require(
            _mintAmount <= maxNftsPerTx,
            "You cannot mint more than allowed Nfts per tx !!"
        );
        require(
            totalSupply() + _mintAmount <= maxNfts,
            "All Katty Nfts are solded out !!"
        );

        require(
            nftsMintedBalance[_user] + _mintAmount <= nftsLimitPerAddress,
            "You cannot mint more Nfts !!"
        );

        _;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (revealed == false) {
            return hiddenTokenURI;
        }

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        ".json"
                    )
                )
                : "";
    }

    function setPrice(uint256 _newPrice) public onlyOwner {
        price = _newPrice * 1 ether;
    }

    function setMaxNftsPerTx(uint256 _newLimit) public onlyOwner {
        maxNftsPerTx = _newLimit;
    }

    function setNftLimitPerAddress(uint256 _newLimit) public onlyOwner {
        nftsLimitPerAddress = _newLimit;
    }

    function togglePaused() public onlyOwner {
        paused = !paused;
    }

    function togglePresale() public onlyOwner {
        presale = !presale;
    }

    function revealNfts() public onlyOwner {
        revealed = true;
    }

    function setBaseTokenURI(string memory _newBaseTokenURI) public onlyOwner {
        baseTokenURI = _newBaseTokenURI;
    }

    function setHiddenURI(string memory _newHiddenTokenUri) public onlyOwner {
        hiddenTokenURI = _newHiddenTokenUri;
    }

    function whitelistUsers(address[] memory addresses) public onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            whitelistedAddresses[addresses[i]] = true;
        }
    }

    function removeWhitelistUsers(address[] memory addresses) public onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            whitelistedAddresses[addresses[i]] = false;
        }
    }

    function withdraw() public onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }
}
