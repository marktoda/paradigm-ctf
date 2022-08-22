// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./Car.sol";

contract RampUp is Car {
    constructor(Monaco _monaco) Car(_monaco) {
    }

    function takeYourTurn(Monaco.CarData[] calldata allCars, uint256 ourCarIndex) external override {
        Monaco.CarData memory ourCar = allCars[ourCarIndex];

        // later on in the race get more aggressive
        uint32 raceProgression = allCars[0].y / 100 + 1; // 1-10
        uint256 threshold = 8 + raceProgression;

        maintainSpeed(ourCar, threshold, raceProgression);


        if (ourCarIndex == 0) {
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
        uint256 baseBalanceMultiple = raceProgression >= 8 ? 0 : 8 - raceProgression;
        if (ourCar.speed < threshold) {
            uint256 balanceMultiple = baseBalanceMultiple + (11 - raceProgression);

            if (ourCar.balance > monaco.getAccelerateCost(threshold - ourCar.speed) * balanceMultiple) {
                ourCar.balance -= uint24(monaco.buyAcceleration(threshold - ourCar.speed));
            } else if (ourCar.balance > monaco.getAccelerateCost(3) * balanceMultiple) {
                ourCar.balance -= uint24(monaco.buyAcceleration(3));
            }
        } else {
            uint256 balanceMultiple = baseBalanceMultiple + (22 - raceProgression * 2);
            if (ourCar.balance > monaco.getAccelerateCost(3) * balanceMultiple) {
                ourCar.balance -= uint24(monaco.buyAcceleration(3));
            }
        }
    }
}
