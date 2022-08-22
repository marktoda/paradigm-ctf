// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/console2.sol";
import "forge-std/Test.sol";
import "../src/rescue/Setup.sol";
import "../src/rescue/Exploiter.sol";

contract RescueTest is Test {
    Setup setup = Setup(0x1DeD76422C7DB7d972CC2246F7aaca0a2E07404d);
    address public constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant usdt = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public constant dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    function setUp() public {
    }

    function testRescue() public {
        vm.createSelectFork(vm.rpcUrl("paradigm"));
        Exploiter exp = new Exploiter();
        vm.deal(address(exp), 11 ether);
        exp.rescue();
        console2.log(setup.isSolved());
    }
}
