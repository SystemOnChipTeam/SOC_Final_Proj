// Tests for SRLI (Shift Right Logical Immediate)
// Logic: rd = rs1 >> imm[4:0] (Zero-extended)
// Constraints: Only addi, beq, j, lui, li, and srli.

.extern return_srli_test
.extern fail
.section .text.init
.globl srli_test
.type srli_test, @function

srli_test:

    # -----------------------------------------------------------------
    # Test 1: Basic Shift Right Immediate
    # Logic: 16 >> 4 = 1
    # -----------------------------------------------------------------
test_srli_1:
    li      t1, 16
    srli    t3, t1, 4
    li      t4, 1
    beq     t3, t4, test_srli_2
    j       Fail_Srli_1

    # -----------------------------------------------------------------
    # Test 2: Shift Right Immediate by Zero (Identity)
    # Logic: 0xABC >> 0 = 0xABC
    # -----------------------------------------------------------------
test_srli_2:
    li      t1, 0xABC
    srli    t3, t1, 0
    li      t4, 0xABC
    beq     t3, t4, test_srli_3
    j       Fail_Srli_2

    # -----------------------------------------------------------------
    # Test 3: Shift MSB to LSB (Tests zero-fill property)
    # Logic: 0x80000000 >> 31 = 1
    # -----------------------------------------------------------------
test_srli_3:
    lui     t1, 0x80000         # 0x80000000
    srli    t3, t1, 31
    li      t4, 1               # MSB moved to LSB, rest is zeroes
    beq     t3, t4, pass_srli
    j       Fail_Srli_3

pass_srli:
    j return_srli_test

# --- Failure Handlers ---
Fail_Srli_1:
    li gp, 1441
    j fail
Fail_Srli_2:
    li gp, 1442
    j fail
Fail_Srli_3:
    li gp, 1443
    j fail
