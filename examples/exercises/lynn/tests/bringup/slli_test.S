// Tests for SLLI (Shift Left Logical Immediate)
// Logic: rd = rs1 << imm[4:0]
// Constraints: Only addi, beq, j, lui, li, and slli.

.extern return_slli_test
.extern fail
.section .text.init
.globl slli_test
.type slli_test, @function

slli_test:

    # -----------------------------------------------------------------
    # Test 1: Basic Shift Left Immediate
    # Logic: 1 << 4 = 16
    # -----------------------------------------------------------------
test_slli_1:
    li      t1, 1
    slli    t3, t1, 4
    li      t4, 16
    beq     t3, t4, test_slli_2
    j       Fail_Slli_1

    # -----------------------------------------------------------------
    # Test 2: Shift Left Immediate by Zero (Identity)
    # Logic: 0xABC << 0 = 0xABC
    # -----------------------------------------------------------------
test_slli_2:
    li      t1, 0xABC
    slli    t3, t1, 0
    li      t4, 0xABC
    beq     t3, t4, test_slli_3
    j       Fail_Slli_2

    # -----------------------------------------------------------------
    # Test 3: Shift Immediate to MSB
    # Logic: 1 << 31 = 0x80000000
    # -----------------------------------------------------------------
test_slli_3:
    li      t1, 1
    slli    t3, t1, 31
    lui     t4, 0x80000         # 0x80000000
    beq     t3, t4, pass_slli
    j       Fail_Slli_3

pass_slli:
    j return_slli_test

# --- Failure Handlers ---
Fail_Slli_1:
    li gp, 1411
    j fail
Fail_Slli_2:
    li gp, 1412
    j fail
Fail_Slli_3:
    li gp, 1413
    j fail
