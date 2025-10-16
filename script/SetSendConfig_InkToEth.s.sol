// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import { ILayerZeroEndpointV2 } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import { UlnConfig } from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";
import { ExecutorConfig } from "@layerzerolabs/lz-evm-messagelib-v2/contracts/SendLibBase.sol";
import { SetConfigParam } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol";

contract SetSendConfig_InkToEth is Script {
    // ---- Hardcoded network constants (Ink) ----
    address constant INK_ENDPOINT   = 0xca29f3A6f966Cb2fc0dE625F8f325c0C46dbE958; // EndpointV2
    address constant INK_SEND_LIB   = 0x76111DE813F83AAAdBD62773Bf41247634e2319a; // SendUln302
    address constant INK_EXECUTOR   = 0xFEbCF17b11376C724AB5a5229803C6e838b6eAe5; // Executor
    uint32  constant ETH_EID        = 30101;                                      // Ethereum EID

    // Use LayerZero Labs DVN **on INK** for this pathway
    address constant DVN_INK_LABS   = 0x174F2bA26f8ADeAfA82663bcf908288d5DbCa649;

    // Tweak if you want, but keep both sides equal
    uint32  constant MAX_MESSAGE_SZ = 10_000;

    function run() external {
        // Your local deployment specifics
        address oapp = vm.envAddress("OAPP_INK");          // your OApp/OFT on Ink
        uint256 pk   = vm.envUint("PK");                   // broadcaster PK

        // Before the struct literal or call...
        address[] memory requiredDVNsLocal = new address[](2);
        requiredDVNsLocal[0] = 0x174F2bA26f8ADeAfA82663bcf908288d5DbCa649;
        requiredDVNsLocal[1] = 0x1E4CE74ccf5498B19900649D9196e64BAb592451; // Replace with new DVN address on Ethereum

        UlnConfig memory uln = UlnConfig({
            confirmations:        20,                                      // minimum block confirmations required on A before sending to B
            requiredDVNCount:     2,                                       // number of DVNs required
            optionalDVNCount:     type(uint8).max,                         // optional DVNs count, uint8
            optionalDVNThreshold: 0,                                       // optional DVN threshold
            requiredDVNs:        requiredDVNsLocal, // sorted list of required DVN addresses
            optionalDVNs:        new address[](0)                          // sorted list of optional DVNs
        });

        // --- Executor (send) ---
        ExecutorConfig memory ex = ExecutorConfig({
            executor:       INK_EXECUTOR,
            maxMessageSize: MAX_MESSAGE_SZ
        });

        SetConfigParam[] memory params = new SetConfigParam[](2);
        params[0] = SetConfigParam({
            eid: ETH_EID,
            configType: 1,                 // EXECUTOR
            config: abi.encode(ex)
        });
        params[1] = SetConfigParam({
            eid: ETH_EID,
            configType: 2,                 // ULN
            config: abi.encode(uln)
        });

        vm.startBroadcast(pk);
        ILayerZeroEndpointV2(INK_ENDPOINT).setConfig(oapp, INK_SEND_LIB, params);
        vm.stopBroadcast();
    }
}
