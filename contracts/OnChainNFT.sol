// SPDX-License-Identifier: MIT

// Amended by @simon-masterclass from the HashLips Art Engine

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Base64.sol";

contract OnChainNFT is ERC721Enumerable, Ownable {
    using Strings for uint256;

    uint256 public cost = 0.05 ether;
    uint256 public maxSupply = 100;
    bool public paused = false;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {}

    // public
    function mint() public payable {
        uint256 supply = totalSupply();
        require(!paused);
        require(supply + 1 <= maxSupply);
        require(
            balanceOf(msg.sender) < 1,
            "You can only mint one NFT per wallet"
        );
        if (msg.sender != owner()) {
            require(msg.value >= cost);
        }
        _safeMint(msg.sender, supply + 1);
    }

    function buildImage() public view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<svg width="555" height="555" xmlns="http://www.w3.org/2000/svg">',
                    '<rect stroke="#000" height="555" width="555" y="0" x="0" fill="#000" />',
                    '<text dominant-baseline="middle" style="cursor: pointer;" text-anchor="middle" font-family="Impact" font-size="111" y="34%" x="50%" stroke="#000000" fill="#ffffff">ZERO ARMY</text>',
                    "",
                    "",
                    "",
                    '<text dominant-baseline="middle" text-anchor="middle" font-family="Courier" font-size="55" stroke-width="2" y="69%" x="50%" stroke="#a10000" fill="#ffffff">Bravo Company</text>',
                    "</svg>"
                )
            );
    }

    function walletOfOwner(
        address _owner
    ) public view returns (uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return "";
    }

    //only owner
    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmount = _newmaxMintAmount;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    function withdraw() public payable onlyOwner {
        // This will pay HashLips 5% of the initial sale.
        // You can remove this if you want, or keep it in to support HashLips and his channel.
        // =============================================================================
        (bool hs, ) = payable(0x943590A42C27D08e3744202c4Ae5eD55c2dE240D).call{
            value: (address(this).balance * 5) / 100
        }("");
        require(hs);
        // =============================================================================

        // This will payout the owner 95% of the contract balance.
        // Do not remove this otherwise you will not be able to withdraw the funds.
        // =============================================================================
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
        // =============================================================================
    }
}
