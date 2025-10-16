// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {OApp} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OApp.sol";

contract SetDelegate is Script {
    function run(address oftAddress, address newDelegate, string memory chain) external {
        uint256 deployerPrivateKey = vm.envUint("PK");
        vm.startBroadcast(deployerPrivateKey);

        OApp oft = OApp(oftAddress);
        oft.setDelegate(newDelegate);

        console2.log("Delegate set to:", newDelegate, "on", chain, "contract:", oftAddress);

        vm.stopBroadcast();
    }
}