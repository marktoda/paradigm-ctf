// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/console2.sol";
import "forge-std/Test.sol";
import "../src/reversing/Setup.sol";
import "../src/reversing/Abcd.sol";

contract ReversingTest is Test {

    function setUp() public {
    }

    function testReversing() public {
        vm.createSelectFork(vm.rpcUrl("paradigm"));
        Setup setup = new Setup();
        ChallengeInterface chal = ChallengeInterface(address(setup.deployer()));


        /**

msg.data 
00 0xc64b3bb5
04 0000000000000000000000000000000000000000000000000000000000000020
24 0000000000000000000000000000000000000000000000000000000000000040
44 000000000000000000000000000000000000000000000000000000000000002a
64 0000000000000000000000000000000000000000000000000000000000000044



            var var2 = storage[0x00] & 0xff;

            var temp0 = 0x80; // freemempointer

            # memory[0x80] = true if storage[0] low byte is nonzero else false
            memory[temp0:temp0 + 0x20] = !!var2;
            var temp1 = 0x80; // still freemempointer
            # memory[0x80:0xa0]
            return memory[temp1:temp1 + (temp0 + 0x20) - temp1];
            
            function solved() {
                return sload[0x00] & 0xff;

            }
         */

        /**
         *
            var1 = 0x006f;
            pointer, size = getData(msg.data.length, 0x04);

            function getData(msgDataLength, 4) {
                var0 = 0x00
                var1 = 0x00
                require(msgDataLength >= 36)
                tailOffset = msg.data[0x04:0x24]
                require(tailOffset <= 0xffffffffffffffff)
                tailPointer = 4 + tailOffset;
                require(tailPointer + 0x1f < msgDataLength);
                dataLength = msg.data[tailOffset + 4:tailOffset + 24]
                require(dataLength <= 0xffffffffffffffff)
                require(tailOffset + dataLength + 36 <= msgDataLength); 

                return (tailPointer + 32, dataLength)
                return (tailOffset + 36, msg.data[tailOffset + 4:tailOffset + 24])
            }

            size == 2a

            var var4 = pointer
            var var5 = size;
            var var6 = 0x00;

            var temp2 = ((msg.data[44:64] >> 0xf8) << 0xf8) & 0xff00000000000000000000000000000000000000000000000000000000000000 == 0x05 << 0xfc;

            var4 = ((msg.data[45:65 + var4 + 0x20] >> 0xf8) << 0xf8) & ~((0x01 << 0xf8) - 0x01) == 0x43 << 0xf8;


            # head
            00 0x00000000 // 4 bytes of selector
            04 0x20 offset of the tail not including the selector

            # tail
            24 0x40 bytes size // 0x40 (2 words)

            # data
            44 0x000000000000000000000000000000000000000000000000000000000000002a // magic word to get past the first if
            64 0x0000000000000000000000000000000000000000000000000000000000000044 // pointer to 0x24
            // <= 0xffffffffffffffff
            // < dataLength - 35


            var4 = 0x0211
            var4 = func_0B92()
            function func_0B92() returns (var r0) {
                var temp0 = memory[0x40:0x60]; // freemempointer, 0x80
                var var0 = temp0;               // ditto, 0x80
                memory[0x40:0x60] = var0 + 0xc0;  // 0x140, add 6 slots to freemem pointer
                var var1 = 0x06;
                var var2 = var0; // old freemempointer, 0x80
                var3 = func_0BBF(); // 0x140

            label_0BA9:
                var temp1 = var2; // 0x80
                memory[temp1:temp1 + 0x20] = var3; // memory[0x80:0x100] = 0x140
                var1 = var1 - 0x01; // 0x05 first time, decrementing each call
                var2 = temp1 + 0x20;
            
                if (!var1) { return var0; }
            
                var3 = 0x0ba9;
                var3 = func_0BBF();
                goto label_0BA9;
            }


           function func_0BBF() returns (var r0) {
                var temp0 = memory[0x40:0x60]; // 0x140, freemempointer
                memory[0x40:0x60] = temp0 + 0xc0; // 0x200, add 6 more slots
                memory[temp0:temp0 + 0x06 * 0x20] = msg.data[msg.data.length:msg.data.length + 0x06 * 0x20]; // hack to get 6 slots of 0s i think
                return temp0;
            }



            // in label_022a
            var6 = 0x00
            var7 = 0x006a;
            var8 = 0x2a; // data length
            var9 = 0x00;
            var10 = 0x0237;
            var11 = 0x2a; // data length 
            var12 = 0x06;
            var10 = func_0CB4(var11, var12); // 0x2a * 6 = 0xfc
            var11 = var10; // 0x0237
            var10 = 0x0242;
            var12 = 0x05;
            var10 = func_0CD3(var11, var12); // 0x023c
            var temp109 = var9; // 0x00
            var9 = 0x024c;
            var temp110 = var10; // 0x023c
            var10 = temp109; // 0x00
            var11 = temp110; // 0x023c
            var9 = safeAdd(var10, var11); // 0x023c

            if var9 < var8 // if 0x023c < 0x2a

            function func_0CB4(var arg0 // data length, var arg1 // 6) returns (var r0) {
                var var0 = 0x00;
                var temp0 = arg1; // 6
            
                // when arg0 > 42 (255 / 6), assert arg1 is odd, else assert it is even
                if (!(!!temp0 & (arg0 > ~0x00 / temp0))) { return arg1 * arg0; }
            
                var var1 = 0x0cce;
                memory[0x00:0x20] = 0x4e487b71 << 0xe0;
                memory[0x04:0x24] = 0x11;
                revert(memory[0x00:0x24]);
            }

            function safeAdd(var arg0, var arg1) returns (var r0) {
                var temp0 = arg1; // 0x023c
                var var0 = arg0 + temp0; // 0x00 + 0x023c

                if (temp0 <= var0) { return var0; }
         *
         */

        /* setup.challenge(); */
        /* console2.logBytes(address(chal).code); */
        /* console2.logBytes(address(chal).code); */
        chal.check(hex"504354467baaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa7d");
        /* address(chal).call(hex"c64b3bb50000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000002a504354467baaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa7d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"); */
        /* vm.store(address(chal), 0x0, hex"0000000000000000000000000000000000000000000000000000000000000001"); */
        /* require(chal.solved(), "failed"); */
    }
}
