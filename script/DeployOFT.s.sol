
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {CatOFT} from "../src/CatOFT.sol";

/**
 * Usage (per chain):
 *  - Set LZ_ENDPOINT to that chain's EndpointV2 address
 *  - Set OWNER to your EOA (receives initial supply if >0)
 *  - Set INITIAL_SUPPLY (wei, e.g., 1000000 ether for canonical; 0 for remote)
 *
 * forge script script/DeployOFT.s.sol \

 *   --rpc-url $RPC_ETH_SEPOLIA --broadcast \

 *   --env-path .env -vvvv
 */
contract DeployOFT is Script {
    function run() external {
        address endpoint = vm.envAddress("LZ_ENDPOINT");
        address owner = vm.envAddress("OWNER");
        uint256 initialSupply = vm.envOr("INITIAL_SUPPLY", uint256(0));

        uint256 pk = vm.envUint("PK");
        vm.startBroadcast(pk);
        CatOFT oft = new CatOFT(endpoint, owner, initialSupply);
        vm.stopBroadcast();

        console.log("CatOFT deployed at:", address(oft));
        console.log("EndpointV2:", endpoint);
        console.log("Owner:", owner);
        console.log("InitialSupply:", initialSupply);
    }
}
