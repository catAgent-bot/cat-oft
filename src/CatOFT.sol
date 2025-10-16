// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {OFT} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/OFT.sol";

/**
 * Minimal OFT v2 — OFT already includes Ownable via OApp.
 */
contract CatOFT is OFT {
    constructor(address endpoint, address owner_, uint256 initialSupply)
        OFT("Cat Token", "CAT", endpoint, owner_)   // <-- this is required
    {
        if (initialSupply > 0) {
            _mint(owner_, initialSupply);
        }
    }
}
