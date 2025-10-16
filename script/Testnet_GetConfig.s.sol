// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import {ILayerZeroEndpointV2} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {UlnConfig} from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";
import {ExecutorConfig} from "@layerzerolabs/lz-evm-messagelib-v2/contracts/SendLibBase.sol";

contract GetConfigScript is Script {
    uint32 constant CONFIG_TYPE_EXECUTOR = 1;
    uint32 constant CONFIG_TYPE_ULN = 2;

    function run() external view {
        address endpoint = vm.envAddress("LZ_ENDPOINT");
        address oapp     = vm.envAddress("OAPP");
        uint32  eid      = uint32(vm.envUint("REMOTE_EID"));

        ILayerZeroEndpointV2 ep = ILayerZeroEndpointV2(endpoint);

        // Resolve the active libraries (defaults if you didn't set custom ones)
        address sendLib = ep.getSendLibrary(oapp, eid);
        (address recvLib, ) = ep.getReceiveLibrary(oapp, eid);

        bytes memory sendUlnBytes = ep.getConfig(oapp, sendLib, eid, CONFIG_TYPE_ULN);
        bytes memory recvUlnBytes = ep.getConfig(oapp, recvLib, eid, CONFIG_TYPE_ULN);

        UlnConfig memory sendUln = abi.decode(sendUlnBytes, (UlnConfig));
        UlnConfig memory recvUln = abi.decode(recvUlnBytes, (UlnConfig));

        console2.log("--- SEND (src->dst) ULN ---");
        console2.log("confirmations", sendUln.confirmations);
        console2.log("requiredDVNCount", sendUln.requiredDVNCount);
        for (uint i; i<sendUln.requiredDVNs.length; i++) console2.logAddress(sendUln.requiredDVNs[i]);

        console2.log("--- RECV (dst expects) ULN ---");
        console2.log("confirmations", recvUln.confirmations);
        console2.log("requiredDVNCount", recvUln.requiredDVNCount);
        for (uint i; i<recvUln.requiredDVNs.length; i++) console2.logAddress(recvUln.requiredDVNs[i]);
    }
}
