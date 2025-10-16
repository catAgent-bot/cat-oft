// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import {IOFT, SendParam, MessagingFee} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/interfaces/IOFT.sol";
import {OptionsBuilder} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OptionsBuilder.sol";

contract SendViaAdapter is Script {
    using OptionsBuilder for bytes;

    function run() external {
        uint256 pk = vm.envUint("PK");
        address ADAPTER_INK = vm.envAddress("ADAPTER_INK");
        uint32  DST_EID     = uint32(vm.envUint("EID_ETH"));
        address TO          = vm.envAddress("TO");
        uint256 AMOUNT      = vm.envUint("AMOUNT");

        bytes memory opts = OptionsBuilder.newOptions()
            .addExecutorLzReceiveOption(150_000, 0); // adjust if needed

        SendParam memory p = SendParam({
            dstEid: DST_EID,
            to: bytes32(uint256(uint160(TO))),
            amountLD: AMOUNT,
            minAmountLD: AMOUNT,
            extraOptions: opts,
            composeMsg: "",
            oftCmd: ""
        });

        vm.startBroadcast(pk);
        MessagingFee memory fee = IOFT(ADAPTER_INK).quoteSend(p, false);
        IOFT(ADAPTER_INK).send{value: fee.nativeFee}(p, fee, msg.sender);
        vm.stopBroadcast();

        console2.log("quoted native fee", fee.nativeFee);
    }
}