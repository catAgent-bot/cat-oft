// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import { ILayerZeroEndpointV2 } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import { UlnConfig } from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";
import { ExecutorConfig } from "@layerzerolabs/lz-evm-messagelib-v2/contracts/SendLibBase.sol";
import { SetConfigParam } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol";

contract SetSendConfig_EthToInk is Script {
    // ---- Ethereum side (source) ----
    address constant ETH_ENDPOINT   = 0x1a44076050125825900e736c501f859c50fE728c; // EndpointV2
    address constant ETH_SEND_LIB   = 0xbB2Ea70C9E858123480642Cf96acbcCE1372dCe1; // SendUln302
    address constant ETH_EXECUTOR   = 0x173272739Bd7Aa6e4e214714048a9fE699453059; // Executor
    uint32  constant INK_EID        = 30339;                                       // Ink EID

    // Use LayerZero Labs DVN on **Ethereum**
    address constant DVN_ETH_LABS   = 0x589dEDbD617e0CBcB916A9223F4d1300c294236b;

    // Tweak if you want, but keep both sides equal
    uint32  constant MAX_MESSAGE_SZ = 10_000;

    function run() external {
        address oapp = vm.envAddress("OAPP_ETH"); // your OApp/OFT on Ethereum
        uint256 pk   = vm.envUint("PK");

        address[] memory requiredDVNsLocal = new address[](2);
        requiredDVNsLocal[0] = 0x589dEDbD617e0CBcB916A9223F4d1300c294236b;
        requiredDVNsLocal[1] = 0xa4fE5A5B9A846458a70Cd0748228aED3bF65c2cd;

        UlnConfig memory uln = UlnConfig({
            confirmations:        15,
            requiredDVNCount:     2,
            optionalDVNCount:     type(uint8).max,
            optionalDVNThreshold: 0,
            requiredDVNs:         requiredDVNsLocal,
            optionalDVNs:         new address[](0)
        });

        ExecutorConfig memory ex = ExecutorConfig({
            executor:       ETH_EXECUTOR,
            maxMessageSize: MAX_MESSAGE_SZ
        });

        SetConfigParam[] memory params = new SetConfigParam[](2);
        params[0] = SetConfigParam({
            eid: INK_EID,
            configType: 1, // EXECUTOR
            config: abi.encode(ex)
        });
        params[1] = SetConfigParam({
            eid: INK_EID,
            configType: 2, // ULN
            config: abi.encode(uln)
        });

        vm.startBroadcast(pk);
        ILayerZeroEndpointV2(ETH_ENDPOINT).setConfig(oapp, ETH_SEND_LIB, params);
        vm.stopBroadcast();
    }
}
