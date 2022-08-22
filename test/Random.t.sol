// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/console2.sol";
import "forge-std/Test.sol";
import "../src/random/Setup.sol";

contract RandomTest is Test {
    Setup setup = Setup(0x8F6D2131620b0762e1763BE211c6B5cEbBEb8A4e);

    function setUp() public {
    }

    function testRandom() public {
        vm.createSelectFork(vm.rpcUrl("paradigm"));
        console2.log(address(setup.random()));
    }
}
