// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "forge-std/console2.sol";
import "./Car.sol";

contract PennyPincher is Car {
    uint256 sumAccelPrice = 20;
    uint256 sumShellPrice = 200;
    uint256 count;

    constructor(Monaco _monaco) Car(_monaco) {
    }

    function takeYourTurn(Monaco.CarData[] calldata allCars, uint256 ourCarIndex) external override {
        Monaco.CarData memory ourCar = allCars[ourCarIndex];
        uint32 raceProgression = allCars[0].y; // 1-999
        uint256 overpaymentThreshold = 100 + raceProgression / 10 + 10; // 10-100% over
        count += 1;

        if (ourCar.speed == 1) {
            uint256 speed = maintainSpeed(overpaymentThreshold * 2, ourCar.balance);
            if (speed > 0) ourCar.balance -= uint24(monaco.buyAcceleration(speed));
        } else {
            uint256 speed = maintainSpeed(overpaymentThreshold, ourCar.balance);
            if (speed > 0) ourCar.balance -= uint24(monaco.buyAcceleration(speed));
        }


        if (ourCarIndex > 0) {
            Monaco.CarData memory carInFront = allCars[ourCarIndex - 1];
            if (shouldShell(overpaymentThreshold, ourCar.balance)) {
                ourCar.balance -= uint24(monaco.buyShell(1));
            } else if (carInFront.balance < 100 && shouldShell(200, ourCar.balance)) {
                // they're poor, so we can probably kick them out with a shell
                ourCar.balance -= uint24(monaco.buyShell(1));
            } else if (raceProgression > 980 && monaco.getShellCost(1) < ourCar.balance && carInFront.speed > 3) {
                ourCar.balance -= uint24(monaco.buyShell(1));
            }
        }
    }

    function maintainSpeed(uint256 overpaymentThreshold, uint256 maxCost) internal returns (uint256 speed) {
        uint256 averagePrice = averageAccelPrice(monaco.getAccelerateCost(1));
        uint256 priceThreshold = averagePrice * overpaymentThreshold / 100;
        console2.log("threshold", priceThreshold);
        for (uint256 i = 10; i >= 1; i--) {
            uint256 cost = monaco.getAccelerateCost(i);
            if (cost / i <= priceThreshold && cost < maxCost) {
                return i;
            }
        }
    }

    function shouldShell(uint256 overpaymentThreshold, uint256 maxCost) internal returns (bool isCheap) {
        /* uint256 cheapPrice = raceProgression / 3 + 100; // 100-266 */
        uint256 price = monaco.getShellCost(1);
        uint256 averagePrice = averageShellPrice(price);
        uint256 priceThreshold = averagePrice * overpaymentThreshold / 100;
        if (price <= priceThreshold && price < maxCost) {
            return true;
        }
    }

    function averageAccelPrice(uint256 current) internal returns (uint256 average) {
        average = sumAccelPrice / count;
        console2.log("sum", sumAccelPrice);
        console2.log("avg", average);
        console2.log("cur", current);
        sumAccelPrice += current;
    }

    function averageShellPrice(uint256 current) internal returns (uint256 average) {
        average = sumShellPrice / count;
        sumShellPrice += current;
    }
}
