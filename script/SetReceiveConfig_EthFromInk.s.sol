// script/SetReceiveConfig_EthFromInk.s.sol
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import { ILayerZeroEndpointV2 } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import { UlnConfig } from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";
import { SetConfigParam } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol";

contract SetReceiveConfig_EthFromInk is Script {
    // ---- Hardcoded network constants (Ethereum) ----
    address constant ETH_ENDPOINT   = 0x1a44076050125825900e736c501f859c50fE728c; // EndpointV2
    address constant ETH_RECEIVE_LIB= 0xc02Ab410f0734EFa3F14628780e6e695156024C2; // ReceiveUln302
    uint32  constant INK_EID        = 30339;                                      // Ink EID

    function run() external {
        address oapp = vm.envAddress("OAPP_ETH"); // your OApp/OFT on Ethereum
        uint256 pk   = vm.envUint("PK");

        address[] memory requiredDVNsLocal = new address[](2);
        requiredDVNsLocal[0] = 0x589dEDbD617e0CBcB916A9223F4d1300c294236b;
        requiredDVNsLocal[1] = 0xa4fE5A5B9A846458a70Cd0748228aED3bF65c2cd;

        UlnConfig memory uln = UlnConfig({
            confirmations:        20,                                      // minimum block confirmations required on A before sending to B
            requiredDVNCount:     2,                                       // number of DVNs required
            optionalDVNCount:     type(uint8).max,                         // optional DVNs count, uint8
            optionalDVNThreshold: 0,                                       // optional DVN threshold
            requiredDVNs:        requiredDVNsLocal, // sorted list of required DVN addresses
            optionalDVNs:        new address[](0)                          // sorted list of optional DVNs
        });

        SetConfigParam[] memory params = new SetConfigParam[](1);
        params[0] = SetConfigParam({
            eid: INK_EID,
            configType: 2,                 // ULN (receive)
            config: abi.encode(uln)
        });

        vm.startBroadcast(pk);
        ILayerZeroEndpointV2(ETH_ENDPOINT).setConfig(oapp, ETH_RECEIVE_LIB, params);
        vm.stopBroadcast();
    }
}