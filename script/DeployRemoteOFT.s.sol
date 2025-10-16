// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import {RemoteCatOFT} from "../src/adapter/RemoteCatOFT.sol";

contract DeployRemoteOFT is Script {
    function run() external {
        address endpoint = vm.envAddress("LZ_ENDPOINT_ETH");
        address owner = vm.envAddress("OWNER");
        uint256 pk = vm.envUint("PK");

        vm.startBroadcast(pk);
        RemoteCatOFT oft = new RemoteCatOFT(endpoint, owner);
        vm.stopBroadcast();

        console2.log("RemoteCatOFT (ETH):", address(oft));
    }
}