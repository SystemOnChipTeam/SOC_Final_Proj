// Tests for SRL (Shift Right Logical)
// Logic: rd = rs1 >> rs2[4:0] (Zero-fill)
// Constraints: Only addi, beq, j, lui, li, and srl.

.extern return_srl_test
.extern fail
.section .text.init
.globl srl_test
.type srl_test, @function

srl_test:

    # -----------------------------------------------------------------
    # Test 1: Basic Shift Right
    # Logic: 16 >> 2 = 4
    # -----------------------------------------------------------------
test_srl_1:
    li      t1, 16
    li      t2, 2
    srl     t3, t1, t2
    li      t4, 4
    beq     t3, t4, test_srl_2
    j       Fail_Srl_1

    # -----------------------------------------------------------------
    # Test 2: MSB Zero-Fill Check
    # Logic: 0x80000000 >> 31 = 1 (Must NOT sign-extend)
    # -----------------------------------------------------------------
test_srl_2:
    lui     t1, 0x80000         # 0x80000000 (MSB is 1)
    li      t2, 31
    srl     t3, t1, t2
    li      t4, 1               # Should be exactly 1, no leading 1s
    beq     t3, t4, test_srl_3
    j       Fail_Srl_2

    # -----------------------------------------------------------------
    # Test 3: Shift Right by Zero
    # Logic: 0xFFF >> 0 = 0xFFF
    # -----------------------------------------------------------------
test_srl_3:
    li      t1, 0xFFF
    li      t2, 0
    srl     t3, t1, t2
    li      t4, 0xFFF
    beq     t3, t4, pass_srl
    j       Fail_Srl_3

pass_srl:
    j return_srl_test

# --- Failure Handlers ---
Fail_Srl_1:
    li gp, 1401
    j fail
Fail_Srl_2:
    li gp, 1402
    j fail
Fail_Srl_3:
    li gp, 1403
    j fail
