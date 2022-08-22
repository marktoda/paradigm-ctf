// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "forge-std/console2.sol";
import "./Car.sol";

contract PhasedCar is Car {
    constructor(Monaco _monaco) Car(_monaco) {
    }

    function takeYourTurn(Monaco.CarData[] calldata allCars, uint256 ourCarIndex) external override {
        uint32 raceProgression = allCars[0].y / 100 + 1; // 1-10

        if (allCars[0].y > 990) {
            actualEndGame(allCars, ourCarIndex);
        } else if (raceProgression == 10) {
            endGame(allCars, ourCarIndex);
        } else if (raceProgression >= 8) {
            lateGame(allCars, ourCarIndex);
        } else if (raceProgression >= 5) {
            midGame(allCars, ourCarIndex);
        } else if (raceProgression >= 2){
            earlyGame(allCars, ourCarIndex);
        } 
    }

    // goals: 
    // - save money
    // - stay close
    function earlyGame(Monaco.CarData[] calldata cars, uint256 ourCarIndex) internal {
        Monaco.CarData memory ourCar = cars[ourCarIndex];

        uint256 shellCost = monaco.getShellCost(1);

        // might as well just buy one to raise the price for other dummies
        if (shellCost < 30 && cars[ourCarIndex].balance > shellCost) {
            console2.log("shells cheap, gonna buy one", shellCost);
            ourCar.balance -= uint24(monaco.buyShell(1));
        }
        
        if (ourCarIndex == 0) {
            if (cars[1].speed > ourCar.speed) {
                uint256 speed = maxAcceleration(ourCar.balance / 80);
                if (speed > 0) ourCar.balance -= uint24(monaco.buyAcceleration(speed));
            } else {
                uint256 speed = maxAcceleration(ourCar.balance / 100);
                if (speed > 0) ourCar.balance -= uint24(monaco.buyAcceleration(speed));
            }
        } else if (ourCarIndex == 1) {
            uint32 yDiff = cars[0].y - ourCar.y;
            if (yDiff > 50 && cars[0].speed > ourCar.speed && cars[0].speed > 5 && monaco.getShellCost(1) < ourCar.balance / 25) {
                ourCar.balance -= uint24(monaco.buyShell(1));
            }

            if (cars[0].speed > ourCar.speed) {
                uint256 speed = maxAcceleration(ourCar.balance / 80);
                if (speed > 0) ourCar.balance -= uint24(monaco.buyAcceleration(speed));
            }
        } else {
            uint32 yDiffFront = cars[1].y - ourCar.y;
            if (cars[1].speed > ourCar.speed) {
                uint256 speed = maxAcceleration(ourCar.balance / 70);
                if (speed > 0) ourCar.balance -= uint24(monaco.buyAcceleration(speed));
            }
        }
    }

    // goals:
    // - move toward the front
    // - conserve money for the late game
    function midGame(Monaco.CarData[] calldata cars, uint256 ourCarIndex) internal {
        Monaco.CarData memory ourCar = cars[ourCarIndex];
        uint256 shellCost = monaco.getShellCost(1);

        // might as well just buy one to raise the price for other dummies
        if (shellCost < 40 && cars[ourCarIndex].balance > shellCost) {
            console2.log("shells cheap, gonna buy one", shellCost);
            ourCar.balance -= uint24(monaco.buyShell(1));
        }

        if (ourCarIndex == 0) {
            if (cars[1].speed > ourCar.speed) {
                uint256 speed = maxAcceleration(ourCar.balance / 50);
                if (speed > 0) ourCar.balance -= uint24(monaco.buyAcceleration(speed));
            } else {
                uint256 speed = maxAcceleration(ourCar.balance / 80);
                if (speed > 0) ourCar.balance -= uint24(monaco.buyAcceleration(speed));
            }
        } else if (ourCarIndex == 1) {
            uint32 yDiff = cars[0].y - ourCar.y;
            if (yDiff > 50 && cars[0].speed > ourCar.speed && cars[0].speed > 5 && monaco.getShellCost(1) < ourCar.balance / 15) {
                ourCar.balance -= uint24(monaco.buyShell(1));
            }

            if (cars[0].speed > ourCar.speed) {
                uint256 speed = maxAcceleration(ourCar.balance / 40);
                if (speed > 0) ourCar.balance -= uint24(monaco.buyAcceleration(speed));
            }
        } else {
            uint32 yDiffFront = cars[0].y - ourCar.y;
            if (yDiffFront > 100) {
                uint256 speed = maxAcceleration(ourCar.balance / 20);
                if (speed > 0) ourCar.balance -= uint24(monaco.buyAcceleration(speed));
            } else {
                uint256 speed = maxAcceleration(ourCar.balance / 30);
                if (speed > 0) ourCar.balance -= uint24(monaco.buyAcceleration(speed));

                uint32 yDiffMid = cars[1].y - ourCar.y;
                if (yDiffMid > 50 && cars[1].speed > ourCar.speed && cars[1].speed > 5 && monaco.getShellCost(1) < ourCar.balance / 20) {
                    ourCar.balance -= uint24(monaco.buyShell(1));
                }
            }
        }
    }

    // goals:
    // - get to the front and stay there
    function lateGame(Monaco.CarData[] calldata cars, uint256 ourCarIndex) internal {
        Monaco.CarData memory ourCar = cars[ourCarIndex];
        uint256 shellCost = monaco.getShellCost(1);

        // might as well just buy one to raise the price for other dummies
        if (shellCost < 50 && cars[ourCarIndex].balance > shellCost) {
            console2.log("shells cheap, gonna buy one", shellCost);
            ourCar.balance -= uint24(monaco.buyShell(1));
        }

        if (ourCarIndex == 0) {
            // just got shelled
            if (cars[1].speed > ourCar.speed || cars[2].speed > ourCar.speed) {
                uint256 speed = maxAcceleration(ourCar.balance / 10);
                if (speed > 0) ourCar.balance -= uint24(monaco.buyAcceleration(speed));
            } else if (cars[1].speed > ourCar.speed) {
                uint256 speed = maxAcceleration(ourCar.balance / 30);
                if (speed > 0) ourCar.balance -= uint24(monaco.buyAcceleration(speed));
            }
        } else if (ourCarIndex == 1) {
            if (cars[0].speed > 5 && monaco.getShellCost(1) < ourCar.balance / 10) {
                ourCar.balance -= uint24(monaco.buyShell(1));
            } else if (cars[0].speed > 5 && cars[0].y - cars[1].y > 50 && monaco.getShellCost(1) < ourCar.balance / 5) {
                ourCar.balance -= uint24(monaco.buyShell(1));
            }

            if (cars[0].speed > ourCar.speed) {
                uint256 speed = maxAcceleration(ourCar.balance / 10);
                if (speed > 0) ourCar.balance -= uint24(monaco.buyAcceleration(speed));
            } else {
                uint256 speed = maxAcceleration(ourCar.balance / 30);
                if (speed > 0) ourCar.balance -= uint24(monaco.buyAcceleration(speed));
            }
        } else {
            uint32 yDiffFront = cars[0].y - ourCar.y;
            if (yDiffFront > 100) {
                uint256 speed = maxAcceleration(ourCar.balance / 20);
                if (speed > 0) ourCar.balance -= uint24(monaco.buyAcceleration(speed));
            } else {
                uint256 speed = maxAcceleration(ourCar.balance / 30);
                if (speed > 0) ourCar.balance -= uint24(monaco.buyAcceleration(speed));

                if (cars[0].speed > 5 && monaco.getShellCost(1) < ourCar.balance / 10) {
                    ourCar.balance -= uint24(monaco.buyShell(1));
                }
            }
        }
    }

    function endGame(Monaco.CarData[] calldata cars, uint256 ourCarIndex) internal {
        Monaco.CarData memory ourCar = cars[ourCarIndex];

        uint256 shellCost = monaco.getShellCost(1);

        // might as well just buy one to raise the price for other dummies
        if (shellCost < 60 && cars[ourCarIndex].balance > shellCost) {
            console2.log("shells cheap, gonna buy one", shellCost);
            ourCar.balance -= uint24(monaco.buyShell(1));
        }

        if (ourCarIndex == 0) {
            if (ourCar.speed < 5) {
                uint256 speed = maxAcceleration(ourCar.balance / 3);
                if (speed > 0) ourCar.balance -= uint24(monaco.buyAcceleration(speed));
            } else if (cars[1].speed > ourCar.speed) {
                uint256 speed = maxAcceleration(ourCar.balance / 7);
                if (speed > 0) ourCar.balance -= uint24(monaco.buyAcceleration(speed));
            }
        } else {
            if (monaco.getShellCost(1) < ourCar.balance / 5) {
                ourCar.balance -= uint24(monaco.buyShell(1));
            }

            uint256 speed = maxAcceleration(ourCar.balance);
            if (speed > 0) ourCar.balance -= uint24(monaco.buyAcceleration(speed) / 2);
        }
    }

    function actualEndGame(Monaco.CarData[] calldata cars, uint256 ourCarIndex) internal {
        Monaco.CarData memory ourCar = cars[ourCarIndex];
        if (ourCarIndex == 0) {
            uint256 speed = maxAcceleration(ourCar.balance);
            if (speed > 0) ourCar.balance -= uint24(monaco.buyAcceleration(speed));
        } else {
            if (monaco.getShellCost(1) < ourCar.balance / 2) {
                ourCar.balance -= uint24(monaco.buyShell(1));
            }

            uint256 speed = maxAcceleration(ourCar.balance);
            if (speed > 0) ourCar.balance -= uint24(monaco.buyAcceleration(speed));
        }
    }

    function maxAcceleration(uint32 maxSpend) internal view returns (uint256 speed) {
        for (uint256 i = 10; i >= 1; i--) {
            uint256 cost = monaco.getAccelerateCost(i);
            if (maxSpend >= cost) {
                return i;
            }
        }
    }
}
