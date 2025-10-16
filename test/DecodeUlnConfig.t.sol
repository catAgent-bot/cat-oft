// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

contract DecodeTest is Test {
    struct UlnConfig {
        uint32 confirmations;
        uint32 requiredDVNCount;
        uint32 optionalDVNCount;
        uint8 optionalDVNThreshold;
        address[] requiredDVNs;
        address[] optionalDVNs;
    }

    function testDecodeUlnConfig() public {
        bytes memory data = hex"0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000f00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000589dedbd617e0cbcb916a9223f4d1300c294236b0000000000000000000000000000000000000000000000000000000000000000";

        // Step 1: Decode as bytes
        (bytes memory config) = abi.decode(data, (bytes));
        console.log("Raw config bytes:");
        console.logBytes(config);

        // Step 2: Decode static fields
        try this.decodeStaticFields(config) returns (
            uint32 confirmations,
            uint32 requiredDVNCount,
            uint32 optionalDVNCount,
            uint8 optionalDVNThreshold
        ) {
            console.log("Confirmations:", confirmations);
            console.log("RequiredDVNCount:", requiredDVNCount);
            console.log("OptionalDVNCount:", optionalDVNCount);
            console.log("OptionalDVNThreshold:", optionalDVNThreshold);
        } catch Error(string memory reason) {
            console.log("Static decode failed with reason:", reason);
        } catch (bytes memory lowLevelData) {
            console.log("Static decode failed with low-level error:");
            console.logBytes(lowLevelData);
        }

        // Step 3: Decode requiredDVNs array (offset 0x00c0)
        bytes memory arrayData = slice(config, 192, config.length - 192); // Start at 0x00c0
        console.log("RequiredDVNs array data:");
        console.logBytes(arrayData);

        try this.decodeArray(arrayData) returns (address[] memory requiredDVNs) {
            console.log("RequiredDVNs length:", requiredDVNs.length);
            for (uint i = 0; i < requiredDVNs.length; i++) {
                console.log("RequiredDVN", i, ":", requiredDVNs[i]);
            }
        } catch Error(string memory reason) {
            console.log("Array decode failed with reason:", reason);
        } catch (bytes memory lowLevelData) {
            console.log("Array decode failed with low-level error:");
            console.logBytes(lowLevelData);
        }

        // Step 4: Decode optionalDVNs array (likely empty, check next offset)
        bytes memory optionalArrayData = slice(config, 224, config.length - 224); // Adjust offset if needed
        console.log("OptionalDVNs array data:");
        console.logBytes(optionalArrayData);

        try this.decodeArray(optionalArrayData) returns (address[] memory optionalDVNs) {
            console.log("OptionalDVNs length:", optionalDVNs.length);
            for (uint i = 0; i < optionalDVNs.length; i++) {
                console.log("OptionalDVN", i, ":", optionalDVNs[i]);
            }
        } catch Error(string memory reason) {
            console.log("Optional array decode failed with reason:", reason);
        } catch (bytes memory lowLevelData) {
            console.log("Optional array decode failed with low-level error:");
            console.logBytes(lowLevelData);
        }
    }

    function decodeStaticFields(bytes memory config)
        external
        pure
        returns (uint32, uint32, uint32, uint8)
    {
        return abi.decode(config, (uint32, uint32, uint32, uint8));
    }

    function decodeArray(bytes memory data)
        external
        pure
        returns (address[] memory)
    {
        return abi.decode(data, (address[]));
    }

    function slice(bytes memory data, uint start, uint len) internal pure returns (bytes memory) {
        bytes memory result = new bytes(len);
        for (uint i = 0; i < len && start + i < data.length; i++) {
            result[i] = data[start + i];
        }
        return result;
    }
}