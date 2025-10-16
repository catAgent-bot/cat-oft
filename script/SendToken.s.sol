
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {IOFT, SendParam, MessagingFee} from
    "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/interfaces/IOFT.sol";
import {OptionsBuilder} from
    "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OptionsBuilder.sol";

/**
 * Sends CAT from source chain to destination chain.
 *
 * env:
 *  - SRC_OFT : address of OFT on source chain
 *  - DST_EID : uint32 EID of destination chain
 *  - TO      : recipient on destination chain (EVM)
 *  - AMOUNT  : amount in wei (token decimals)
 *
 * Example:
 *  forge script script/SendToken.s.sol --rpc-url $RPC_ETH_SEPOLIA --broadcast --env-path .env -vvvv
 */
contract SendToken is Script {
    using OptionsBuilder for bytes;

    function run() external {
        address oft = vm.envAddress("SRC_OFT");
        uint32 dstEid = uint32(vm.envUint("DST_EID"));
        address to = vm.envAddress("TO");
        uint256 amount = vm.envUint("AMOUNT");

        bytes memory opts = OptionsBuilder.newOptions()
            .addExecutorLzReceiveOption(150_000, 0); // tune as needed

        SendParam memory p = SendParam({
            dstEid: dstEid,
            to: bytes32(uint256(uint160(to))),
            amountLD: amount,
            minAmountLD: amount,
            extraOptions: opts,
            composeMsg: "",
            oftCmd: ""
        });

        uint256 pk = vm.envUint("PK");
        vm.startBroadcast(pk);
        MessagingFee memory fee = IOFT(oft).quoteSend(p, false); // pay in native
        IOFT(oft).send{value: fee.nativeFee}(p, fee, msg.sender);
        vm.stopBroadcast();

        console.log("Sent");
        console.log(amount);                  // uint256
        console.log(to);                      // address
        console.log("dstEid");
        console.log(uint256(dstEid));         // cast from uint32 -> uint256

        console.log("Native fee paid:");
        console.log(fee.nativeFee);           // uint256
    }
}
