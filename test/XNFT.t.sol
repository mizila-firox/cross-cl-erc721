// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {XNFT} from "src/XNFT.sol";
import {IERC721Receiver} from "lib/openzeppelin-contracts/contracts/interfaces/IERC721Receiver.sol";

contract XNFTTest is Test, IERC721Receiver {
    XNFT xnft;

    function setUp() external {
        xnft = new XNFT(address(this), address(this), 0);
    }

    function testMint() external {
        xnft.mint(address(this), 1);
        string memory uri = xnft.tokenURI(1);
        console.log("uri: %s", uri);

        xnft.mint(address(this), 2);
        string memory uri2 = xnft.tokenURI(2);
        console.log("uri: %s", uri2);
    }

    /****************************************
     *               overrides              *
     ****************************************/

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        console.log("onERC721Received");
        return this.onERC721Received.selector;
    }
}
