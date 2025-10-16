// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import {IOAppCore} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/interfaces/IOAppCore.sol";

contract WirePeers is Script {
    function wireInkToEth() public {
        address ADAPTER_INK = vm.envAddress("ADAPTER_INK");
        address OFT_ETH     = vm.envAddress("OFT_ETH");
        uint32  EID_ETH     = uint32(vm.envUint("EID_ETH"));
        uint256 pk          = vm.envUint("PK");

        require(ADAPTER_INK.code.length > 0, "adapter not a contract on this chain");
        vm.startBroadcast(pk);
        IOAppCore(ADAPTER_INK).setPeer(EID_ETH, bytes32(uint256(uint160(OFT_ETH))));
        vm.stopBroadcast();
    }

    function wireEthToInk() public {
        address OFT_ETH     = vm.envAddress("OFT_ETH");
        address ADAPTER_INK = vm.envAddress("ADAPTER_INK");
        uint32  EID_INK     = uint32(vm.envUint("EID_INK"));
        uint256 pk          = vm.envUint("PK");

        require(OFT_ETH.code.length > 0, "OFT not a contract on this chain");
        vm.startBroadcast(pk);
        IOAppCore(OFT_ETH).setPeer(EID_INK, bytes32(uint256(uint160(ADAPTER_INK))));
        vm.stopBroadcast();
    }

    function run() external { revert("call wireInkToEth() or wireEthToInk()"); }
}