// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {OFTAdapter} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/OFTAdapter.sol";

/**
 * Wraps your existing ERC20 CAT on Ink (canonical).
 * - lock on send (transferFrom user -> this)
 * - unlock on receive (transfer to user)
 *
 * OWNER should be your multisig. OWNER can set peers & configs.
 */
contract CatOFTAdapter is OFTAdapter {
    constructor(address existingCat, address lzEndpoint, address owner_)
        OFTAdapter(existingCat, lzEndpoint, owner_)
    {}
}
