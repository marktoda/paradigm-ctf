// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./Car.sol";

contract FourthCar is Car {
    constructor(Monaco _monaco) Car(_monaco) {
    }

    function takeYourTurn(Monaco.CarData[] calldata allCars, uint256 ourCarIndex) external override {
        Monaco.CarData memory ourCar = allCars[ourCarIndex];

        // later on in the race get more aggressive
        uint32 raceProgression = allCars[0].y / 100 + 1; // 1-10
        uint256 threshold = 8 + raceProgression;

        maintainSpeed(ourCar, threshold, raceProgression);


        if (ourCarIndex == 0) {
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
            if (shellCost < 300 && allCars[ourCarIndex + 1].balance > 300 && ourCar.balance > (1000 * (11 - raceProgression))) {
                ourCar.balance -= uint24(monaco.buyShell(1));
            }
        } else if (ourCarIndex > 0 && allCars[ourCarIndex - 1].speed > 10) {
            uint32 yDiff = allCars[ourCarIndex - 1].y - ourCar.y;
            // way behind
            if (yDiff > 100 && ourCar.balance > monaco.getShellCost(1)) {
                ourCar.balance -= uint24(monaco.buyShell(1));
            } else if (ourCar.balance > monaco.getShellCost(1) * (11 - raceProgression)) {
                ourCar.balance -= uint24(monaco.buyShell(1));
            }
        }
    }

    // kinda trying to monopolize the acceleration
    function maintainSpeed(Monaco.CarData memory ourCar, uint256 threshold, uint32 raceProgression) internal {
        // so000oo slow
        if (ourCar.speed < threshold) {
            if (ourCar.balance > monaco.getAccelerateCost(threshold - ourCar.speed) * (6 - raceProgression / 2)) {
                ourCar.balance -= uint24(monaco.buyAcceleration(threshold - ourCar.speed));
            } else if (ourCar.balance > monaco.getAccelerateCost(3) * (6 - raceProgression / 2)) {
                ourCar.balance -= uint24(monaco.buyAcceleration(3));
            } else if (ourCar.balance > monaco.getAccelerateCost(2) * (6 - raceProgression / 2)) {
                ourCar.balance -= uint24(monaco.buyAcceleration(2));
            }
        } else {
            if (ourCar.balance > monaco.getAccelerateCost(3) * (11 - raceProgression)) {
                ourCar.balance -= uint24(monaco.buyAcceleration(3));
            } else if (ourCar.balance > monaco.getAccelerateCost(2) * (11 - raceProgression)) {
                ourCar.balance -= uint24(monaco.buyAcceleration(2));
            }
        }
    }
}
