// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract SetOwner is Script {
    function run(address oftAddress, address newOwner, string memory chain) external {
        uint256 deployerPrivateKey = vm.envUint("PK");
        vm.startBroadcast(deployerPrivateKey);

        Ownable oft = Ownable(oftAddress);
        oft.transferOwnership(newOwner);

        console2.log("Ownership transferred to:", newOwner, "on", chain, "contract:", oftAddress);

        vm.stopBroadcast();
    }
}