// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./Car.sol";

contract ShellCar is Car {
    constructor(Monaco _monaco) Car(_monaco) {
    }

    function takeYourTurn(Monaco.CarData[] calldata allCars, uint256 ourCarIndex) external override {
        Monaco.CarData memory ourCar = allCars[ourCarIndex];
        uint32 raceProgression = allCars[0].y / 100 + 1; // 1-10
        if (monaco.turns() > 100 && raceProgression < 8) {
            raceProgression = 9;
        } else if (monaco.turns() > 110) {
            raceProgression = 10;
        }

        // prioritize shelling early, then prioritize speed at the end
        if (raceProgression < 8) {
            if (ourCarIndex > 0) {
                maybeShell(ourCar, allCars[ourCarIndex - 1], raceProgression);
            }

            maintainSpeed(ourCar, raceProgression);
        } else {
            maintainSpeed(ourCar, raceProgression);

            if (ourCarIndex > 0) {
                maybeShell(ourCar, allCars[ourCarIndex - 1], raceProgression);
            }
        }
    }

    // very conservative speed management
    function maintainSpeed(Monaco.CarData memory ourCar, uint32 raceProgression) internal {
        uint256 balanceMultiple = 21 - (raceProgression * 2);
        if (raceProgression > 7) {
            balanceMultiple = 11 - (raceProgression);
        }

        if (ourCar.speed < 10 && monaco.getAccelerateCost(3) * balanceMultiple < ourCar.balance) {
            ourCar.balance -= uint24(monaco.buyAcceleration(3));
        } else if (monaco.getAccelerateCost(1) * balanceMultiple < ourCar.balance) {
            ourCar.balance -= uint24(monaco.buyAcceleration(1));
        }
    }

    function maybeShell(Monaco.CarData memory ourCar, Monaco.CarData memory frontCar, uint32 raceProgression) internal {
        // not worth it, should save money to increase our own speed
        if (frontCar.speed < 6) {
            return;
        }

        uint32 yDiff = frontCar.y - ourCar.y;
        // way behind, be more aggro
        if (yDiff > 150) {
            uint256 balanceMultiple = 6 - (raceProgression / 2);
            if (monaco.getShellCost(1) * balanceMultiple < ourCar.balance) {
                ourCar.balance -= uint24(monaco.buyShell(1));
            }
        } else {
            uint256 balanceMultiple = 11 - raceProgression;
            if (monaco.getShellCost(1) * balanceMultiple < ourCar.balance) {
                ourCar.balance -= uint24(monaco.buyShell(1));
            }
        }
    }
}
