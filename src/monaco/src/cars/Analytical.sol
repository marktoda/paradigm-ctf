// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "forge-std/console2.sol";
import "./Car.sol";

contract AnalyticalCar is Car {
    constructor(Monaco _monaco) Car(_monaco) {}

    function takeYourTurn(Monaco.CarData[] calldata allCars, uint256 ourCarIndex) external override {
        Monaco.CarData memory ourCar = allCars[ourCarIndex];

        uint256 accelerateValue = getAccelerateValue(allCars, ourCarIndex);
        uint256 shellValue = getShellValue(allCars, ourCarIndex);

        // prioritize based on which is more valuable
        if (accelerateValue > shellValue) {
            uint256 speed = maxAccelerate(accelerateValue, ourCar.balance);
            if (speed > 0) ourCar.balance -= uint24(monaco.buyAcceleration(speed));

            if (shell(shellValue, ourCar.balance)) ourCar.balance -= uint24(monaco.buyShell(1));
        } else {
            if (shell(shellValue, ourCar.balance)) ourCar.balance -= uint24(monaco.buyShell(1));

            uint256 speed = maxAccelerate(accelerateValue, ourCar.balance);
            if (speed > 0) ourCar.balance -= uint24(monaco.buyAcceleration(speed));
        }
    }

    function getAccelerateValue(Monaco.CarData[] calldata allCars, uint256 ourCarIndex) internal returns (uint256 value) {
        Monaco.CarData memory ourCar = allCars[ourCarIndex];
    
        value += 100 - (min(ourCar.speed, 20) * 5);
        console2.log("speed value", (100 - (min(ourCar.speed, 20) * 5)));

        value += allCars[0].y / 10;
        console2.log("progression value", (allCars[0].y / 10));

        value += ourCarIndex == 1 ? 25 : ourCarIndex == 2 ? 20 : 0;
        console2.log("accel value", value);
    }

    function getShellValue(Monaco.CarData[] calldata allCars, uint256 ourCarIndex) internal returns (uint256 value) {
        Monaco.CarData memory ourCar = allCars[ourCarIndex];
    
        if (ourCarIndex == 0) {
            value += ourCar.y / 10;
            value += ourCar.speed * 5;
            console2.log("first place shell value", value);
        } else {
            value += allCars[ourCarIndex - 1].speed * 10;
            value += allCars[ourCarIndex - 1].y - ourCar.y;
            value += allCars[0].y / 10;
            console2.log("behind place shell value", value);
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
}
