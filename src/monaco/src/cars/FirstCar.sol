// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./Car.sol";

contract FirstCar is Car {
    constructor(Monaco _monaco) Car(_monaco) {}

    function takeYourTurn(Monaco.CarData[] calldata allCars, uint256 ourCarIndex) external override {
        Monaco.CarData memory ourCar = allCars[ourCarIndex];
        // if accelerating is cheap, just do it anyways

        if (ourCarIndex == 0) {
        // we're in the lead
            uint256 accelerateCost = monaco.getAccelerateCost(1);
            uint256 shellCost = monaco.getShellCost(1);

            // were probably gonna get shelled but
            // if acceleration is cheap do it anyways to make it more expensive for them :D
            if (accelerateCost < 10 && ourCar.balance > 100) {
                ourCar.balance -= uint24(monaco.buyAcceleration(1));
            } else if (accelerateCost < 50 && ourCar.balance > 1000) {
                ourCar.balance -= uint24(monaco.buyAcceleration(1));
            }

            // same for shell
            if (shellCost < 300 && ourCar.balance > 1000) {
                ourCar.balance -= uint24(monaco.buyShell(1));
            }
        } else if (ourCarIndex < allCars.length / 2) {
        // we're in the top half
            uint256 accelerateCost = monaco.getAccelerateCost(2);
            uint256 shellCost = monaco.getShellCost(1);
            if (allCars[ourCarIndex - 1].speed > ourCar.speed || allCars[ourCarIndex + 1].speed > ourCar.speed) {
                // speed problem. lets accelerate if we have extra cash
                if (ourCar.balance > accelerateCost + shellCost) {
                    ourCar.balance -= uint24(monaco.buyAcceleration(2));
                }

                if (ourCar.balance > shellCost) {
                    // rip it!
                    ourCar.balance -= uint24(monaco.buyShell(1));

                }
            }

        } else {
        // we're in the bottom half
        // just accelerate, shells not worth it
            if (ourCar.balance > monaco.getAccelerateCost(3)) {
                ourCar.balance -= uint24(monaco.buyAcceleration(3));
            } else if (ourCar.balance > monaco.getAccelerateCost(2)) {
                ourCar.balance -= uint24(monaco.buyAcceleration(2));
            } else if (ourCar.balance > monaco.getAccelerateCost(1)) {
                ourCar.balance -= uint24(monaco.buyAcceleration(1));
            }

        }
    }
}
