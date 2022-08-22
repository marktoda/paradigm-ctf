// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "forge-std/console2.sol";
import "forge-std/Test.sol";

import "../src/Monaco.sol";
import "../src/cars/Learning2.sol";
import "../src/cars/PhasedCar.sol";
import "../src/cars/ShellCar.sol";

contract MonacoTest is Test {
    Monaco monaco;

    function setUp() public {
        monaco = new Monaco();
    }

    function testGames() public {
LearningCar2 w1 = new LearningCar2(monaco);
        console2.log("analytical", address(w1));
        ShellCar w3 = new ShellCar(monaco);
        console2.log("shell", address(w3));
        PhasedCar w2 = new PhasedCar(monaco);
        console2.log("dynamic", address(w2));

        monaco.register(w1);
        monaco.register(w2);
        monaco.register(w3);

        // You can throw these CSV logs into Excel/Sheets/Numbers or a similar tool to visualize a race!
        vm.writeFile(string.concat("logs/", vm.toString(address(w1)), ".csv"), "turns,balance,speed,y\n");
        vm.writeFile(string.concat("logs/", vm.toString(address(w2)), ".csv"), "turns,balance,speed,y\n");
        vm.writeFile(string.concat("logs/", vm.toString(address(w3)), ".csv"), "turns,balance,speed,y\n");
        vm.writeFile("logs/prices.csv", "turns,accelerateCost,shellCost\n");
        vm.writeFile("logs/sold.csv", "turns,acceleratesBought,shellsBought\n");

        while (monaco.state() != Monaco.State.DONE) {
            monaco.play(1);

            emit log("");

            Monaco.CarData[] memory allCarData = monaco.getAllCarData();

            for (uint256 i = 0; i < allCarData.length; i++) {
                Monaco.CarData memory car = allCarData[i];

                emit log_address(address(car.car));
                emit log_named_uint("balance", car.balance);
                emit log_named_uint("speed", car.speed);
                emit log_named_uint("y", car.y);

                vm.writeLine(
                    string.concat("logs/", vm.toString(address(car.car)), ".csv"),
                    string.concat(
                        vm.toString(uint256(monaco.turns())),
                        ",",
                        vm.toString(car.balance),
                        ",",
                        vm.toString(car.speed),
                        ",",
                        vm.toString(car.y)
                    )
                );

                vm.writeLine(
                    "logs/prices.csv",
                    string.concat(
                        vm.toString(uint256(monaco.turns())),
                        ",",
                        vm.toString(monaco.getAccelerateCost(1)),
                        ",",
                        vm.toString(monaco.getShellCost(1))
                    )
                );

                vm.writeLine(
                    "logs/sold.csv",
                    string.concat(
                        vm.toString(uint256(monaco.turns())),
                        ",",
                        vm.toString(monaco.getActionsSold(Monaco.ActionType.ACCELERATE)),
                        ",",
                        vm.toString(monaco.getActionsSold(Monaco.ActionType.SHELL))
                    )
                );
            }
        }

        emit log_named_uint("Number Of Turns", monaco.turns());
    }
}
