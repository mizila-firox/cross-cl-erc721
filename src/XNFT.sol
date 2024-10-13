// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {ERC721} from "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {OwnerIsCreator} from "lib/chainlink/contracts/src/v0.8/shared/access/OwnerIsCreator.sol";

// ccip. better to separate token from ccip, different files, for now lets keep it like this
import {Client} from "lib/chainlink/contracts/src/v0.8/ccip/libraries/Client.sol";
import {IRouterClient} from "lib/chainlink/contracts/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {CCIPReceiver} from "lib/chainlink/contracts/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";

contract XNFT is ERC721, ERC721URIStorage, OwnerIsCreator, CCIPReceiver {
    IRouterClient public router;
    IERC20 public linkToken;
    uint64 public originChainSelector; // origin chain selector

    uint8 public constant MAX_SUPPLY = 8;

    // uint256 public currentId = 1;

    // events
    event XNFT__CrossChainMinted(address indexed to, uint256 indexed tokenId);

    constructor(
        address _routerAddress,
        address _linkTokenAddress,
        uint64 _originChainSelector
    ) ERC721("XNFT Super Mario World", "XSMW") CCIPReceiver(_routerAddress) {
        router = IRouterClient(_routerAddress);
        linkToken = IERC20(_linkTokenAddress);
        originChainSelector = _originChainSelector;
        linkToken.approve(_routerAddress, type(uint256).max);
    }

    /****************************************
     *                 ccip                 *
     ****************************************/

    function _ccipReceive(
        Client.Any2EVMMessage memory message
    ) internal override {
        (bool success, ) = address(this).call(message.data);
        require(success, "XNFT: failed to mint token");
        // mint token in the destination chain
    }

    function transferCrossChain(
        address _to,
        uint256 _tokenId,
        uint64 _destinationChainSelector
    ) public returns (bytes32 receipt) {
        // checking if user owns the token id
        require(
            ownerOf(_tokenId) == msg.sender || msg.sender == owner(),
            "XNFT: You do not own this token"
        );

        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(_to),
            data: abi.encodeWithSignature(
                "mint(address,uint256)",
                0x7E8d7BFd6cc6B05d056f2E46860D95038f2E3234,
                _tokenId
            ),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            feeToken: address(linkToken),
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 950_000})
            )
        });

        uint256 ccipFee = router.getFee(_destinationChainSelector, message);

        if (ccipFee > linkToken.balanceOf(address(this))) {
            revert("Insufficient fee token amount");
        }

        // transfer link token to router
        linkToken.approve(address(router), ccipFee);

        // burn token in this chain to mint in the destination chain
        require(ownerOf(_tokenId) != address(0), "token does not exist");

        _burn(_tokenId);

        receipt = router.ccipSend(_destinationChainSelector, message);
    }

    /****************************************
     *                erc721                *
     ****************************************/

    mapping(uint8 => address) public tokenAlreadyMinted;

    modifier onlyOnFuji() {
        require(
            block.chainid == 43113,
            "XNFT: Only allowed be minted on chain Fuji [43113]"
        );
        _;
    }

    // not secure so far, later add access control so one entity can mint on every chain
    // not secure so far, later add access control so one entity can mint on every chain
    function mint(address _to, uint256 _tokenId) public {
        require(_tokenId <= MAX_SUPPLY, "XNFT out of bounds");
        _mint(_to, _tokenId);

        emit XNFT__CrossChainMinted(_to, _tokenId);
    }

    /****************************************
     *               overrides              *
     ****************************************/

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, ERC721URIStorage, CCIPReceiver)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721URIStorage, ERC721) returns (string memory) {
        return string(abi.encodePacked(super.tokenURI(tokenId), ".json"));
    }

    function _baseURI() internal pure override returns (string memory) {
        // jsons
        return
            "https://scarlet-scared-wildcat-411.mypinata.cloud/ipfs/Qmb6tWBDLd9j2oSnvSNhE314WFL7SRpQNtfwjFWsStXp5A/";

        // jpgs
        // return
        //     "https://scarlet-scared-wildcat-411.mypinata.cloud/ipfs/QmXPdhZunk5psvpvWCHpg99G8TRSyPpzn46p5DjJbzrS4h/";
    }
}
