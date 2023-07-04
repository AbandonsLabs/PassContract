//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC721A.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./IERC721A.sol";
import "./src/DefaultOperatorFilterer.sol";

contract AbandonsLabs is
    ERC721A,
    Ownable,
    ReentrancyGuard,
    DefaultOperatorFilterer
{
    error MaxSupplyExceeded();
    error NotAllowlisted();
    error MaxPerWalletExceeded();
    error InsufficientValue();
    error PublicSaleNotActive();
    error NoContracts();
    error AllowlistNotActive();
    error InvalidPassType();

    event BronzeMinted(address indexed buyer, uint256 tokenId);
    event SilverMinted(address indexed buyer, uint256 tokenId);
    event GoldMinted(address indexed buyer, uint256 tokenId);
    event DiamondMinted(address indexed buyer, uint256 tokenId);

    uint256 public publicBronzeCost = 0.05 ether;
    uint256 public publicSilverCost = 0.15 ether;
    uint256 public publicGoldCost = 0.35 ether;
    uint256 public publicDiamondCost = 1 ether;

    mapping(uint256 => uint8) public tokenIdToPassType;

    uint256 public maxSupply = 500;

    uint8 public maxMintAmount = 1;

    mapping(uint8 => string) public _baseTokenURI;

    bool public publicSaleActive;

    constructor() ERC721A("ABANDONS LABS PHEONIX PASS", "AbandonsLabsPass") {
        _mint(msg.sender, 1);
        tokenIdToPassType[1] = 1;
        _mint(msg.sender, 1);
        tokenIdToPassType[2] = 2;
        _mint(msg.sender, 1);
        tokenIdToPassType[3] = 3;
        _mint(msg.sender, 1);
        tokenIdToPassType[4] = 4;
        _baseTokenURI[
            1
        ] = "https://nftstorage.link/ipfs/bafybeidmjd2ypbj7h4d3dicadcaoccveb4u5wk2edr2bgq3l64swvqd6cq/";

        _baseTokenURI[
            2
        ] = "https://nftstorage.link/ipfs/bafybeifjdmcpss5f5icpvrag5qchcroye5mpz6o4ayokk22fhrsobf2sna/";

        _baseTokenURI[
            3
        ] = "https://nftstorage.link/ipfs/bafybeic3rb7vcmkjpc45jxq6o6jthcezt2gu5ontuqofrpyakoch2k56oe/";

        _baseTokenURI[
            4
        ] = "https://nftstorage.link/ipfs/bafybeiaxa4bug7hagnsm7cckm6kn7gex647h7ccu2q7dpwrtt7lt4lkic4/";

    }

    modifier callerIsUser() {
        if (msg.sender != tx.origin) revert NoContracts();
        _;
    }

    function setSilverCost(uint256 _newSilverCost) external onlyOwner {
        publicSilverCost = _newSilverCost;
    }

    function setGoldCost(uint256 _newGoldCost) external onlyOwner {
        publicGoldCost = _newGoldCost;
    }

    function setDiamondCost(uint256 _newDiamondCost) external onlyOwner {
        publicDiamondCost = _newDiamondCost;
    }

    function setBronzeCost(uint256 _newBronzeCost) external onlyOwner {
        publicBronzeCost = _newBronzeCost;
    }

    function mint(uint8 _passType) external payable callerIsUser nonReentrant {
        if (!publicSaleActive) revert AllowlistNotActive();
        if (_passType > 4 || _passType == 0) revert InvalidPassType();
        if (totalSupply() + 1 > maxSupply)
            revert MaxSupplyExceeded();
        if (_numberMinted(msg.sender) + 1 > maxMintAmount)
            revert MaxPerWalletExceeded();
        if (_passType == 1) {
            if (msg.value != publicBronzeCost) revert InsufficientValue();
            mintBronze(msg.sender);
        }
        if (_passType == 2) {
            if (msg.value != publicSilverCost) revert InsufficientValue();
            mintSilver(msg.sender);
        }
        if (_passType == 3) {
            if (msg.value != publicGoldCost) revert InsufficientValue();
            mintGold(msg.sender);
        }
        if (_passType == 4) {
            if (msg.value != publicDiamondCost) revert InsufficientValue();
            mintDiamond(msg.sender);
        }
    }

    function mintBronze(address _user) private {
        _mint(_user, 1);
        tokenIdToPassType[totalSupply()] = 1;
    }

    function mintSilver(address _user) private {
        _mint(_user, 1);
        tokenIdToPassType[totalSupply()] = 2;
    }

    function mintGold(address _user) private {
      _mint(_user, 1);
        tokenIdToPassType[totalSupply()] = 3;
    }

    function mintDiamond(address _user) private {
      _mint(_user, 1);
      tokenIdToPassType[totalSupply()] = 4;
    }


    function airDrop(
        address[] calldata targets,
        uint8 passType
    ) external onlyOwner {
        if (passType > 4 || passType == 0) revert InvalidPassType();
        if (targets.length + totalSupply() > maxSupply)
            revert MaxSupplyExceeded();

        for (uint256 i = 0; i < targets.length; i++) {
            if (passType == 1) {
                mintBronze(targets[i]);
            }
            if (passType == 2) {
                mintSilver(targets[i]);
            }
            if (passType == 3) {
                mintGold(targets[i]);
            }
            if (passType == 4) {
                mintDiamond(targets[i]);
            }
        }
    }

    function numberMinted(address _user) external view returns (uint256) {
        return _numberMinted(_user);
    }

    function setMaxMintAmount(uint8 _maxMintAmount) external onlyOwner {
        maxMintAmount = _maxMintAmount;
    }

    function _baseURI(
        uint256 tokenId
    ) internal view virtual override returns (string memory) {
        return _baseTokenURI[tokenIdToPassType[tokenId]];
    }

    function setBaseURI(
        string calldata baseURI,
        uint8 passType
    ) external onlyOwner {
        _baseTokenURI[passType] = baseURI;
    }

    function togglePublicSale() external onlyOwner {
        publicSaleActive = !publicSaleActive;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable override onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public payable override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function withdraw() external onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function emergencyWithdraw() external onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        (bool successOwner, ) = payable(msg.sender).call{value: balance}("");
        require(successOwner, "Transfer to owner failed");
    }
}
