// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import {CatOFTAdapter} from "../src/adapter/CatOFTAdapter.sol";

contract DeployAdapter is Script {
    function run() external {
        address cat = vm.envAddress("CAT_INK");
        address endpoint = vm.envAddress("LZ_ENDPOINT_INK");
        address owner = vm.envAddress("OWNER");
        uint256 pk = vm.envUint("PK");

        vm.startBroadcast(pk);
        CatOFTAdapter adapter = new CatOFTAdapter(cat, endpoint, owner);
        vm.stopBroadcast();

        console2.log("CatOFTAdapter (Ink):", address(adapter));
    }
}