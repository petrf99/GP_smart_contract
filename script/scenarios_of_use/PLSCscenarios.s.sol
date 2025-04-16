// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "src/Polis.sol";
import "forge-std/console.sol";

/// @title PolisStartUp
/// @notice Step 1. Create first Polis and some Oikoses inside it. Should be run bu the owner of the Polis contract (Dev)
contract PolisStartUp is Script {
    function run() external {
        address plscAddress = vm.envAddress("PLSC_SEPOLIA_ADDRESS");
        Polis polis = Polis(plscAddress);

        address GD = vm.envAddress("PUBLIC_KEY_GD"); // GD = Genesis Development - business owner of the system

        uint256 nOikoses = 5;

        vm.startBroadcast();
        polis.createNewPolis(0);
        console.log("Polis 0 created");

        for (uint256 i = 0; i < nOikoses; i++) {
            polis.createNewOikosToken(GD, "mock", 0, 3); // status = 3 - oikos is on sale
            console.log("Oikos created");
            console.logUint(i);
        }

        vm.stopBroadcast();
    }
}

/// @title TransferOikosToOwners
/// @notice Step 2.1. Some oikoses were purchased by customers. Should be run by GD
contract TransferOikosesToOwners is Script {
    function run() external {
        address plscAddress = vm.envAddress("PLSC_SEPOLIA_ADDRESS");
        Polis polis = Polis(plscAddress);

        address GD = vm.envAddress("PUBLIC_KEY_GD");
        address customer = vm.envAddress("PUBLIC_KEY_CUSTOMER");

        vm.startBroadcast();

        polis.transferFrom(GD, customer, 3);
        console.log("Oikos 3 has been transferred to customer");

        vm.stopBroadcast();
    }
}

/// @title SetTransferredTokenStatus
/// @notice Step 2.2. Change status on "in property". Should be run by Dev.
contract SetTransferredTokenStatus is Script {
    function run() external {
        address plscAddress = vm.envAddress("PLSC_SEPOLIA_ADDRESS");
        Polis polis = Polis(plscAddress);

        vm.startBroadcast();

        polis.setOikosStatus(3, 1); // Status 1 - private property
        console.log("Status updated");

        vm.stopBroadcast();
    }
}

/// @title CheckTransferAndSetPermission
/// @title Step 3. Customer checks his ownership of the Oikos and sets permission on remint (in case he loses his private key). Should be run by Customer.
contract CheckTransferAndSetPermission is Script {
    function run() external {
        address plscAddress = vm.envAddress("PLSC_SEPOLIA_ADDRESS");
        Polis polis = Polis(plscAddress);

        address customer = vm.envAddress("PUBLIC_KEY_CUSTOMER");

        address real_owner = polis.ownerOf(3);

        if (real_owner != customer) {
            console.log("Transfer failed");
        } else {
            console.log("Transfer OK");
        }

        vm.startBroadcast();
        polis.setRemintingPermission(3, true);
        vm.stopBroadcast();

        console.log("Reminting permission on oikos 3 has been set");
    }
}

/// @title RemintLostOikos
/// @notice Step 4. Suppose customer has lost his private key and wants to remint his oikos token. Should be run by Dev (owner of the Polis contract).
contract RemintLostOikos is Script {
    function run() external {
        address plscAddress = vm.envAddress("PLSC_SEPOLIA_ADDRESS");
        Polis polis = Polis(plscAddress);

        address newCustomerAddr = vm.envAddress("PUBLIC_KEY_CUSTOMER_NEW");

        vm.startBroadcast();

        polis.remintOikosToken(3, newCustomerAddr);
        console.log("Oikos token has been reminted");

        vm.stopBroadcast();
    }
}

/// @title CheckSystemState
/// @notice Step 5. Reviews current state of the whole system. Should be run by Dev.
contract CheckSystemState is Script {
    function run() external view {
        address plscAddress = vm.envAddress("PLSC_SEPOLIA_ADDRESS");
        Polis polis = Polis(plscAddress);

        uint256[] memory oikosList1to4 = polis.getOikosList(0, 5, 1, 4);

        for (uint256 i = 0; i < 5; i++) {
            console.log("OikosId");
            console.logUint(oikosList1to4[i]);

            console.log("Oikos Status");
            try polis.getOikosStatus(oikosList1to4[i]) returns (uint8 status) {
                console.logUint(status);
            } catch Error(string memory reason) {
                console.log("Error");
                console.logUint(i);
                console.log(reason);
            }

            console.log("Parent Polis");
            try polis.getParentPolis(oikosList1to4[i]) returns (uint16 pp) {
                console.logUint(pp);
            } catch Error(string memory reason) {
                console.log("Error");
                console.logUint(i);
                console.log(reason);
            }

            console.log("OwnerOf");
            try polis.ownerOf(oikosList1to4[i]) returns (address owner) {
                console.logAddress(owner);
            } catch Error(string memory reason) {
                console.log("Error");
                console.logUint(i);
                console.log(reason);
            }
        }

        uint256[] memory oikosList0 = polis.getOikosList(0, 5, 0, 0);

        for (uint256 i = 0; i < 5; i++) {
            console.log("OikosId");
            console.logUint(oikosList0[i]);

            console.log("Oikos Status");
            try polis.getOikosStatus(oikosList0[i]) returns (uint8 status) {
                console.logUint(status);
            } catch Error(string memory reason) {
                console.log("Error");
                console.logUint(i);
                console.log(reason);
            }

            console.log("Parent Polis");
            try polis.getParentPolis(oikosList0[i]) returns (uint16 pp) {
                console.logUint(pp);
            } catch Error(string memory reason) {
                console.log("Error");
                console.logUint(i);
                console.log(reason);
            }

            console.log("OwnerOf");
            try polis.ownerOf(oikosList0[i]) returns (address owner) {
                console.logAddress(owner);
            } catch Error(string memory reason) {
                console.log("Error");
                console.logUint(i);
                console.log(reason);
            }
        }
    }
}
