// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import {ILayerZeroEndpointV2} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {UlnConfig} from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";
import {ExecutorConfig} from "@layerzerolabs/lz-evm-messagelib-v2/contracts/SendLibBase.sol";

contract GetConfigScript is Script {
    uint32 constant CONFIG_TYPE_EXECUTOR = 1;
    uint32 constant CONFIG_TYPE_ULN      = 2;

    function _recvLib(address ep, address oapp, uint32 eid) internal view returns (address lib) {
        bytes4 selABool   = bytes4(keccak256("getReceiveLibrary(address,uint32)")); // both variants share selector
        (bool ok, bytes memory data) = ep.staticcall(abi.encodeWithSelector(selABool, oapp, eid));
        require(ok && data.length >= 32, "getReceiveLibrary failed");

        // Try decode (address,bool)
        if (data.length == 64) {
            (address l, bool isDefault) = abi.decode(data, (address, bool));
            isDefault; // silence “unused variable” warning            
            return l;
        }
        // Or (address,bytes32)
        if (data.length == 64 + 32) {
            (address l, bytes32 ver) = abi.decode(data, (address, bytes32));
            ver;
            return l;
        }
        // Or just (address)
        (address lonly) = abi.decode(data, (address));
        return lonly;
    }

    function run() external view {
        address endpoint = vm.envAddress("LZ_ENDPOINT");   // this chain’s endpoint
        address oapp     = vm.envAddress("OAPP");          // OApp on THIS chain
        uint32  eid      = uint32(vm.envUint("REMOTE_EID")); // remote EID

        ILayerZeroEndpointV2 ep = ILayerZeroEndpointV2(endpoint);

        // libs in use for this path
        address sendLib = ep.getSendLibrary(oapp, eid);
        address recvLib = _recvLib(address(ep), oapp, eid);

        // ULN (DVNs + confirmations)
        UlnConfig memory sendUln = abi.decode(
            ep.getConfig(oapp, sendLib, eid, CONFIG_TYPE_ULN), (UlnConfig)
        );
        UlnConfig memory recvUln = abi.decode(
            ep.getConfig(oapp, recvLib, eid, CONFIG_TYPE_ULN), (UlnConfig)
        );

        console2.log("=== ULN: SEND (src->dst) ===");
        console2.log("sendLib         ", sendLib);
        console2.log("confirmations   ", sendUln.confirmations);
        console2.log("requiredDVNCount", sendUln.requiredDVNCount);
        for (uint i; i < sendUln.requiredDVNs.length; i++) console2.log("requiredDVN     ", sendUln.requiredDVNs[i]);
        for (uint i; i < sendUln.optionalDVNs.length; i++) console2.log("optionalDVN     ", sendUln.optionalDVNs[i]);

        console2.log("=== ULN: RECV (dst expects) ===");
        console2.log("recvLib         ", recvLib);
        console2.log("confirmations   ", recvUln.confirmations);
        console2.log("requiredDVNCount", recvUln.requiredDVNCount);
        for (uint i; i < recvUln.requiredDVNs.length; i++) console2.log("requiredDVN     ", recvUln.requiredDVNs[i]);
        for (uint i; i < recvUln.optionalDVNs.length; i++) console2.log("optionalDVN     ", recvUln.optionalDVNs[i]);

        // Executor (receive gas, etc.)
        ExecutorConfig memory sendExec = abi.decode(
            ep.getConfig(oapp, sendLib, eid, CONFIG_TYPE_EXECUTOR), (ExecutorConfig)
        );
        ExecutorConfig memory recvExec = abi.decode(
            ep.getConfig(oapp, recvLib, eid, CONFIG_TYPE_EXECUTOR), (ExecutorConfig)
        );

        console2.log("=== EXECUTOR: SEND (src->dst) ===");
        console2.log("executor       ", sendExec.executor);
        console2.log("maxMessageSize", sendExec.maxMessageSize);

        console2.log("=== EXECUTOR: RECV (dst expects) ===");
        console2.log("executor       ", recvExec.executor);
        console2.log("maxMessageSize", recvExec.maxMessageSize);
    }
}
