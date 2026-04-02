// C Runtime entry point
// James Kaden Cassidy
// kacassidy@hmc.edu
// 1/21/2026

.extern return_xor_test
.extern fail

 .section .text.init
 .globl xor_test
 .type xor_test, @function

xor_test:
 test1:
 li t0, 0xF0 # 11110000
 li t1, 0x0F # 00001111
 xor t2, t0, t1 # Result should be 0xFF (11111111)
 // beq x0, x0, pass
 li t3, 0xFF
 beq t2, t3, test2
 j Fail_Xor_1

 test2:
 li t0, 0xAA # 10101010
 li t1, 0xAA # 10101010
 xor t2, t0, t1 # Result should be 0x00 (Self-XOR)
 li t3, 0x00
 beq t2, t3, pass
 j Fail_Xor_2

 pass:
 j return_xor_test

Fail_Xor_1:
 li gp, 601
 j fail

Fail_Xor_2:
 li gp, 602
 j fail
