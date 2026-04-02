.extern return_xori_test
.extern fail

 .section .text.init
 .globl xori_test
 .type xori_test, @function

xori_test:
 xori_test1:
 # -----------------------------------------------------------------
 # Test 1: Basic Bit Toggling
 # Pattern: 11110000 (0xF0) ^ 00001111 (0x0F) = 11111111 (0xFF)
 # -----------------------------------------------------------------
 li t0, 0xF0 # Load 240

 # Target Instruction:
 xori t1, t0, 0x0F # t1 = t0 ^ 15
 beq x0, x0, pass
 li t2, 0xFF # Expected result (255)

 # Verify
 beq t1, t2, xori_test2
 j Fail_Xori_1

 xori_test2:
 # -----------------------------------------------------------------
 # Test 2: Sign Extension Check
 # 0 ^ -1 = -1 (0xFFFFFFFF)
 # -----------------------------------------------------------------
 li t0, 0

 # Target Instruction:
 # The immediate -1 (0xFFF) must be sign-extended to 0xFFFFFFFF
 xori t1, t0, -1

 # Verification Trick:
 # Since 'lui' is banned, we can't easily load 0xFFFFFFFF to compare.
 # Instead, we add 1 to the result. If it was 0xFFFFFFFF, it becomes 0.
 addi t2, t1, 1

 li t3, 0
 beq t2, t3, pass
 j Fail_Xori_2

 pass:
 j return_xori_test

Fail_Xori_1:
 li gp, 651 # Error code for XORI basic
 j fail

Fail_Xori_2:
 li gp, 652 # Error code for XORI sign-extend
 j fail
