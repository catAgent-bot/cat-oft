// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/Script.sol";

interface ILayerZeroEndpointV2 {
    function getSendLibrary(address oapp, uint32 dstEid) external view returns (address);
    function getConfig(address oapp, address lib, uint32 eid, uint32 configType) external view returns (bytes memory);
}

interface IOAppCore {
    function setConfig(address lib, uint32 eid, uint32 configType, bytes calldata config) external;
}

import {UlnConfig}      from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";
import {ExecutorConfig} from "@layerzerolabs/lz-evm-messagelib-v2/contracts/SendLibBase.sol";

contract SetPathConfig_OApp is Script {
    uint32 constant CONFIG_TYPE_EXECUTOR = 1;
    uint32 constant CONFIG_TYPE_ULN      = 2;

    function run() external {
        address endpoint  = vm.envAddress("LZ_ENDPOINT");   // this chain’s LZ endpoint
        address oapp      = vm.envAddress("OAPP");          // Adapter/OFT on THIS chain
        uint32  remoteEid = uint32(vm.envUint("REMOTE_EID"));
        uint256 pk        = vm.envUint("PK");

        address executor  = vm.envAddress("EXECUTOR");       // send-side
        uint32  maxMsgSz  = uint32(vm.envUint("MAX_MESSAGE_SIZE"));

        ILayerZeroEndpointV2 ep = ILayerZeroEndpointV2(endpoint);
        address sendLib = ep.getSendLibrary(oapp, remoteEid);
        require(sendLib != address(0), "sendLib=0");

        // --- ULN ---
        bytes memory ulnBytes = ep.getConfig(oapp, sendLib, remoteEid, CONFIG_TYPE_ULN);
        UlnConfig memory uln = abi.decode(ulnBytes, (UlnConfig));
        uln.confirmations = uint16(vm.envUint("CONFIRMATIONS"));

        address[] memory dvns = new address[](1);
        dvns[0] = vm.envAddress("REQUIRED_DVN");
        uln.requiredDVNs = dvns;
        uln.requiredDVNCount = 1;
        // uln.optionalDVNs unchanged

        // --- Executor ---
        bytes memory exBytes = ep.getConfig(oapp, sendLib, remoteEid, CONFIG_TYPE_EXECUTOR);
        ExecutorConfig memory ex = abi.decode(exBytes, (ExecutorConfig));
        ex.executor       = executor;
        ex.maxMessageSize = maxMsgSz;

        vm.startBroadcast(pk);
        IOAppCore(oapp).setConfig(sendLib, remoteEid, CONFIG_TYPE_ULN,      abi.encode(uln));
        IOAppCore(oapp).setConfig(sendLib, remoteEid, CONFIG_TYPE_EXECUTOR, abi.encode(ex));
        vm.stopBroadcast();
    }
}