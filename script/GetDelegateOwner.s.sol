// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {OApp} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OApp.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract VerifyConfig is Script {
    function run(address oftAddress, string memory chain) external view {
        OApp oft = OApp(oftAddress);
        console2.log("Delegate on", chain, ":", oft.delegate());
        console2.log("Owner on", chain, ":", Ownable(oftAddress).owner());
    }
}