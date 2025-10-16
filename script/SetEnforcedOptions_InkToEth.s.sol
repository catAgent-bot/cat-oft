// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import {IOAppOptionsType3, EnforcedOptionParam} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/interfaces/IOAppOptionsType3.sol";
import { OptionsBuilder } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OptionsBuilder.sol";

contract SetEnforcedOptions_InkToEth is Script {
    using OptionsBuilder for bytes;

    uint32 constant ETH_EID = 30101;

    function run() external {
        address oft = vm.envAddress("OAPP_INK");
        uint256 pk = vm.envUint("PK");

        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(65000, 0);

        EnforcedOptionParam[] memory params = new EnforcedOptionParam[](1);
        params[0] = EnforcedOptionParam({
            eid: ETH_EID,
            msgType: 1,
            options: options
        });

        vm.startBroadcast(pk);
        IOAppOptionsType3(oft).setEnforcedOptions(params);
        vm.stopBroadcast();
    }
}