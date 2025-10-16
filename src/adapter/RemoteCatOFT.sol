// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {OFT} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/OFT.sol";

/**
 * Remote omnichain token representation on Ethereum.
 * - burns on send
 * - mints on receive
 */
contract RemoteCatOFT is OFT {
    constructor(address lzEndpoint, address owner_)
        OFT("Cat Call Agent", "CAT", lzEndpoint, owner_)
    {}
}