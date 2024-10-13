// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";
import {XNFT} from "src/XNFT.sol";

contract XNFTScript is Script {
    // fuji
    address routerFuji = 0xF694E193200268f9a4868e4Aa017A0118C9a8177;
    address linkTokenAddressFuji = 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846;
    uint64 chainSelectorFuji = 14767482510784806043;
    IERC20 linkTokenFuji = IERC20(linkTokenAddressFuji);

    address routerSepolia = 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59;
    address linkTokenAddressSepolia =
        0x779877A7B0D9E8603169DdbD7836e478b4624789;
    uint64 chainSelectorSepolia = 16015286601757825753;
    IERC20 linkTokenSepolia = IERC20(linkTokenAddressSepolia);

    ////////////////////
    address payable fuji = payable(0xe194E5B6A71f4dd5f6dEA01DF3201710e6CBceAE);
    address payable sepolia =
        payable(0xAF67BDC24A0311c8cB450E3ea00eAb7073321E99);

    function setUp() external {}

    function run() external {
        vm.startBroadcast();

        /*//////////////////////////////////////////////////////////////
                               DEPLOYMENT
    //////////////////////////////////////////////////////////////*/

        // fuji
        // XNFT xnftFuji = new XNFT(
        //     routerFuji,
        //     linkTokenAddressFuji,
        //     chainSelectorFuji
        // );

        // console.log("xnft address: %s", address(xnftFuji));

        // sepolia
        // XNFT xnftSepolia = new XNFT(
        //     routerSepolia,
        //     linkTokenAddressSepolia,
        //     chainSelectorSepolia
        // );

        // console.log("xnft address: %s", address(xnftSepolia));

        /*//////////////////////////////////////////////////////////////
                               EXECUTION
    //////////////////////////////////////////////////////////////*/

        // fuji
        // XNFT xnft = XNFT(fuji);
        // linkTokenFuji.transfer(fuji, 5 ether);
        // xnft.mint(fuji, 1);
        // console.log(xnft.ownerOf(1));
        // bytes32 receipt = xnft.transferCrossChain(
        //     sepolia,
        //     1,
        //     chainSelectorSepolia
        // );

        // console.logBytes32(receipt);

        // this will only error after sending token 1 to another chain
        // this time around it should error because the user sent the token to another chain, burning this one
        // console.log(xnft.ownerOf(1));

        //////////////////////////////////////////////////////

        // sepolia
        // XNFT xnft = XNFT(sepolia);
        // console.log(xnft.ownerOf(1));
        // linkTokenSepolia.transfer(sepolia, 5 ether);
        // bytes32 receipt = xnft.transferCrossChain(fuji, 1, chainSelectorFuji);
        // console.logBytes32(receipt);

        // this will only error after sending token 1 to another chain
        // this time around it should error because the user sent the token to another chain, burning this one
        // console.log(xnft.ownerOf(1));
    }
}
