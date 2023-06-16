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
    string[] private coderCodeNames;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {}

    // public
    function mint(string memory _coderCodeName) public payable {
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

        coderCodeNames.push(_coderCodeName);
        _safeMint(msg.sender, supply + 1);
    }

    function randomNum(
        uint256 _modulus,
        uint256 _seed,
        uint256 _salt
    ) internal view returns (uint256) {
        uint256 randomNumber = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, msg.sender, _salt, _seed)
            )
        );
        return randomNumber % _modulus;
    }

    function buildImage(
        string memory _nameC0
    ) internal view returns (string memory) {
        return
            Base64.encode(
                bytes(
                    abi.encodePacked(
                        '<svg width="555" height="555" xmlns="http://www.w3.org/2000/svg">',
                        '<rect stroke="#000" height="555" width="555" y="0" x="0" fill="hsl(',
                        randomNum(361, 3, 4).toString(),
                        ',80%,80%)" />',
                        '<text dominant-baseline="middle" text-anchor="middle" font-family="Impact" font-size="111" y="34%" x="50%" stroke="#000000" fill="#ffffff">ZERO ARMY</text>',
                        '<text dominant-baseline="middle" text-anchor="middle" font-family="Courier" font-size="55" stroke-width="2" y="50%" x="50%" stroke="#a10000" fill="#ffffff">BRAVO COMPANY</text>',
                        '<text dominant-baseline="middle" text-anchor="middle" font-family="Courier new" font-size="40" stroke-width="2" y="69%" x="50%" stroke="#ffffff" fill="#ffffff">',
                        _nameC0,
                        "</text>",
                        '<text dominant-baseline="middle" text-anchor="middle" font-family="Courier new" font-size="22" y="88%" x="50%" fill="#ffffff"> HOLDING THE LINE </text>',
                        "</svg>"
                    )
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

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                "Bravo Company",
                                '", "description":"',
                                "Zero Army founding team members - zeroarmy.org",
                                '", "image":"',
                                "data:image/svg+xml;base64,",
                                buildImage(coderCodeNames[tokenId - 1]),
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    //only owner
    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }
`
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
