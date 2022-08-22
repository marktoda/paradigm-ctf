// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/* import "forge-std/console2.sol"; */
import "forge-std/Test.sol";
import "../src/source/Setup.sol";
import "../src/source/Challenge.sol";

contract SourceTest is Test {
    Setup setup;
    Challenge chal;

    function setUp() public {
        setup = new Setup();
        chal = setup.challenge();
    }

    function testSource() public {
        /**
         * 
         * 7c 0x808060181b9060d01c17607c60005360015260301b602152603b6000f3 push29 code // code
         * 80 dup1        // code code
         * 80 dup1        // code code code
         * 
         * 
         * 6018 push1 0x18 // 3*8 code code code -- note shifting over 3 bytes to be properly left aligned
         * 1b shl        // code<<3*8 code code -- note first code takes up top 29 bytes
         * 90 swap1      // code code<<3*8
         * 60d0 push1 0xd0 // push other one over 26 bytes to properly pack
         * 1c shr        // code>>26*8 code<<3*8
         * 17 or         // codecode -- note second code is missing last 26 bytes
         *
         * 607c push1 0x7c 
         * 6000 push1 0x00
         * 53 mstore8    // memory = 70 
         * 
         * 6001 push1 1
         * 52 mstore       // memory = 70codecode -- missing the last 26 bytes
         * 
         * # tacking on the missing bytes into the next slot
         * 6030 push1 0x30  // code (from prev dup) -- note moving over 6 bytes to properly finish last code
         * 1b shl
         * 6021 push1 33
         * 52 mstore
         * 
         * # size
         * 603b push1 59 
         * # offset
         * 6000 push1 00
         * f3 return
         *
         */
        /* vm.createSelectFork(vm.rpcUrl("paradigm")); */
        /* bytes memory input = hex"7faabbccdd00000000000000000000000000000000000000000000000000fedcba60005260046000f3"; */
        bytes memory input = hex"7c808060181b9060d01c17607c60005360015260301b602152603b6000f3808060181b9060d01c17607c60005360015260301b602152603b6000f3";
        chal.solve(input);
    }
}
