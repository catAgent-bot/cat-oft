// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import { ILayerZeroEndpointV2 } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import { UlnConfig } from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";
import { SetConfigParam } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol";

contract SetReceiveConfig_InkFromEth is Script {
    // ---- Ink side (destination) ----
    address constant INK_ENDPOINT     = 0xca29f3A6f966Cb2fc0dE625F8f325c0C46dbE958; // EndpointV2
    address constant INK_RECEIVE_LIB  = 0x473132bb594caEF281c68718F4541f73FE14Dc89; // ReceiveUln302
    uint32  constant ETH_EID          = 30101;                                      // Ethereum EID

    // Use LayerZero Labs DVN on **Ink**
    address constant DVN_INK_LABS     = 0x174F2bA26f8ADeAfA82663bcf908288d5DbCa649;

    function run() external {
        address oapp = vm.envAddress("OAPP_INK"); // your OApp/OFT on Ink
        uint256 pk   = vm.envUint("PK");

        address[] memory requiredDVNsLocal = new address[](2);
        requiredDVNsLocal[0] = DVN_INK_LABS;
        requiredDVNsLocal[1] = 0x1E4CE74ccf5498B19900649D9196e64BAb592451;

        UlnConfig memory uln = UlnConfig({
            confirmations:        15,
            requiredDVNCount:     2,
            optionalDVNCount:     type(uint8).max,
            optionalDVNThreshold: 0,
            requiredDVNs:         requiredDVNsLocal,
            optionalDVNs:         new address[](0)
        });

        SetConfigParam[] memory params = new SetConfigParam[](1);
        params[0] = SetConfigParam({
            eid: ETH_EID,
            configType: 2, // ULN (receive)
            config: abi.encode(uln)
        });

        vm.startBroadcast(pk);
        ILayerZeroEndpointV2(INK_ENDPOINT).setConfig(oapp, INK_RECEIVE_LIB, params);
        vm.stopBroadcast();
    }
}
