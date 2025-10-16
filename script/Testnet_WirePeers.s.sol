
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import "forge-std/console.sol";

interface IOApp {
    function setPeer(uint32 eid, bytes32 peer) external;
}

/**
 * Set the remote peer (run on each chain).
 *
 * env:
 *  - LOCAL_OFT:  address you're configuring (on this chain)
 *  - REMOTE_OFT: address of the OFT on the other chain
 *  - REMOTE_EID: uint32 LayerZero EID for the other chain
 *
 * Example:
 *  forge script script/WirePeers.s.sol --rpc-url $RPC_ETH_SEPOLIA --broadcast --env-path .env
 */
contract WirePeers is Script {
    function run() external {
        address localOft = vm.envAddress("LOCAL_OFT");
        address remoteOft = vm.envAddress("REMOTE_OFT");
        uint32 remoteEid = uint32(vm.envUint("REMOTE_EID"));

        uint256 pk = vm.envUint("PK");
        vm.startBroadcast(pk);
        IOApp(localOft).setPeer(remoteEid, bytes32(uint256(uint160(remoteOft))));
        vm.stopBroadcast();

        console.log("Wired peer:");
        console.log(" local:", localOft);
        console.log(" remote:", remoteOft);
        console.log(" remoteEid:", remoteEid);
    }
}
