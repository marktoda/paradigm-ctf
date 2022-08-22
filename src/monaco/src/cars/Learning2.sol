// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./Car.sol";

contract LearningCar2 is Car {
    constructor(Monaco _monaco) Car(_monaco) {}

    int256 constant ACCEL_SPEED_WEIGHT = 0;
    int256 constant ACCEL_PROGRESSION_WEIGHT = 1122;
    int256 constant ACCEL_PLACE_WEIGHT = 983;
    int256 constant ACCEL_OUR_COINS_WEIGHT = 1133;
    int256 constant ACCEL_NEXT_CAR_COINS_WEIGHT = 911;
    int256 constant SHELL_FIRST_PROGRESSION_WEIGHT = 1368;
    int256 constant SHELL_FIRST_SPEED_WEIGHT = 946;
    int256 constant SHELL_PROGRESSION_WEIGHT = 875;
    int256 constant SHELL_FRONT_SPEED_WEIGHT = 889;
    int256 constant SHELL_Y_DIFF_WEIGHT = 995;
    int256 constant SHELL_OUR_COINS_WEIGHT = 914;
    int256 constant SHELL_NEXT_CAR_COINS_WEIGHT = 1097;
    int256 constant ACCEL_COST_WEIGHT = 1000;
    int256 constant SHELL_COST_WEIGHT = 1000;

    function takeYourTurn(Monaco.CarData[] calldata allCars, uint256 ourCarIndex) external override {
        Monaco.CarData memory ourCar = allCars[ourCarIndex];

        uint256 accelerateValue = normalize(getAccelerateValue(allCars, ourCarIndex));
        uint256 shellValue = normalize(getShellValue(allCars, ourCarIndex));

        // prioritize based on which is more valuable
        if (accelerateValue < 0 && shellValue < 0) {
        } else if (accelerateValue > shellValue) {
            uint256 speed = maxAccelerate(accelerateValue, ourCar.balance);
            if (speed > 0) ourCar.balance -= uint24(monaco.buyAcceleration(speed));

            if (shell(shellValue, ourCar.balance)) ourCar.balance -= uint24(monaco.buyShell(1));
        } else {
            if (shell(shellValue, ourCar.balance)) ourCar.balance -= uint24(monaco.buyShell(1));

            uint256 speed = maxAccelerate(accelerateValue, ourCar.balance);
            if (speed > 0) ourCar.balance -= uint24(monaco.buyAcceleration(speed));
        }
    }

    function getAccelerateValue(Monaco.CarData[] calldata allCars, uint256 ourCarIndex) internal returns (int256 value) {
        Monaco.CarData memory ourCar = allCars[ourCarIndex];
    
        value += int256(uint256(ourCar.speed)) * ACCEL_SPEED_WEIGHT / 10000;

        value += int256(uint256(ourCar.balance)) * ACCEL_OUR_COINS_WEIGHT / 1000000;

        value += int256(uint256(ourCarIndex == 0 ? allCars[1].balance : allCars[ourCarIndex - 1].balance)) * ACCEL_NEXT_CAR_COINS_WEIGHT / 1000000;

        value += int256(uint256(allCars[0].y)) * ACCEL_PROGRESSION_WEIGHT / 10000;

        value += int256(ourCarIndex) * ACCEL_PLACE_WEIGHT / 10000;
        value += int256(ourCarIndex) * ACCEL_COST_WEIGHT / 10000;
        value += int256(ourCarIndex) * SHELL_COST_WEIGHT / 10000;
    }

    function getShellValue(Monaco.CarData[] calldata allCars, uint256 ourCarIndex) internal returns (int256 value) {
        Monaco.CarData memory ourCar = allCars[ourCarIndex];

        value += int256(uint256(ourCar.balance)) * SHELL_OUR_COINS_WEIGHT / 1000000;
        value += int256(uint256(ourCarIndex == 0 ? allCars[1].balance : allCars[ourCarIndex - 1].balance)) * SHELL_NEXT_CAR_COINS_WEIGHT / 1000000;
        value += int256(ourCarIndex) * ACCEL_COST_WEIGHT / 10000;
        value += int256(ourCarIndex) * SHELL_COST_WEIGHT / 10000;

        if (ourCarIndex == 0) {
            value += int256(uint256(ourCar.y)) * SHELL_FIRST_PROGRESSION_WEIGHT / 10000;
            value += int256(uint256(ourCar.speed)) * SHELL_FIRST_SPEED_WEIGHT / 10000;
        } else {
            value += int256(uint256(allCars[ourCarIndex - 1].speed)) * SHELL_FRONT_SPEED_WEIGHT / 10000;
            value += int256(uint256(allCars[ourCarIndex - 1].y - ourCar.y)) * SHELL_Y_DIFF_WEIGHT / 10000;
            value += int256(uint256(ourCar.y)) * SHELL_PROGRESSION_WEIGHT / 10000;
        }
    }

    function min(uint256 a, uint256 b) internal returns (uint256 value) {
        if (a > b) return b;
        return a;
    }

    function max(uint256 a, uint256 b) internal returns (uint256 value) {
        if (a < b) return b;
        return a;
    }

    function maxAccelerate(uint256 targetCost, uint32 maxSpend) internal view returns (uint256 speed) {
        for (uint256 i = 10; i >= 1; i--) {
            uint256 cost = monaco.getAccelerateCost(i);
            if (cost / i <= targetCost && cost < maxSpend) {
                return i;
            }
        }
    }

    function shell(uint256 targetCost, uint32 maxSpend) internal view returns (bool should) {
        uint256 cost = monaco.getShellCost(1);
        if (cost <= targetCost && cost < maxSpend) {
            return true;
        }
    }

    function normalize(int256 cost) internal pure returns (uint256) {
        if (cost < 0) return 0;
        return uint256(cost);
    }
}
