// Tests for SLTU (Set Less Than Unsigned)
// Logic: rd = (rs1 < rs2) ? 1 : 0 (Unsigned comparison)
// Constraints: Only addi, beq, j, lui, li, and sltu.

.extern return_sltu_test
.extern fail
.section .text.init
.globl sltu_test
.type sltu_test, @function

sltu_test:

    # -----------------------------------------------------------------
    # Test 1: Basic Less Than
    # Logic: 5 < 10 = 1
    # -----------------------------------------------------------------
test_sltu_1:
    li      t1, 5
    li      t2, 10
    sltu    t3, t1, t2
    li      t4, 1
    beq     t3, t4, test_sltu_2
    j       Fail_Sltu_1

    # -----------------------------------------------------------------
    # Test 2: Greater Than / Equal
    # Logic: 10 < 5 = 0
    # -----------------------------------------------------------------
test_sltu_2:
    li      t1, 10
    li      t2, 5
    sltu    t3, t1, t2
    li      t4, 0
    beq     t3, t4, test_sltu_3
    j       Fail_Sltu_2

    # -----------------------------------------------------------------
    # Test 3: Signed vs Unsigned Edge Case
    # Logic: 0xFFFFFFFF < 1 = 0 (If it were signed, -1 < 1 is true)
    # -----------------------------------------------------------------
test_sltu_3:
    li      t1, -1              # 0xFFFFFFFF
    li      t2, 1
    sltu    t3, t1, t2
    li      t4, 0               # Unsigned 0xFFFFFFFF is NOT less than 1
    beq     t3, t4, pass_sltu
    j       Fail_Sltu_3

pass_sltu:
    j return_sltu_test

# --- Failure Handlers ---
Fail_Sltu_1:
    li gp, 1431
    j fail
Fail_Sltu_2:
    li gp, 1432
    j fail
Fail_Sltu_3:
    li gp, 1433
    j fail
