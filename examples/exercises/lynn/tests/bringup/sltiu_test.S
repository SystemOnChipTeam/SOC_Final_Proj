// Tests for SLTIU (Set Less Than Immediate Unsigned)
// Logic: rd = (rs1 < unsigned(imm)) ? 1 : 0
// Constraints: Only addi, beq, j, lui, li, and sltiu.

.extern return_sltiu_test
.extern fail
.section .text.init
.globl sltiu_test
.type sltiu_test, @function

sltiu_test:

    # -----------------------------------------------------------------
    # Test 1: Basic Less Than
    # Logic: 5 < 10 = 1
    # -----------------------------------------------------------------
test_sltiu_1:
    li      t1, 5
    sltiu   t3, t1, 10
    li      t4, 1
    beq     t3, t4, test_sltiu_2
    j       Fail_Sltiu_1

    # -----------------------------------------------------------------
    # Test 2: Greater Than / Equal (Should be 0)
    # Logic: 10 < 10 = 0
    # -----------------------------------------------------------------
test_sltiu_2:
    li      t1, 10
    sltiu   t3, t1, 10
    li      t4, 0
    beq     t3, t4, test_sltiu_3
    j       Fail_Sltiu_2

    # -----------------------------------------------------------------
    # Test 3: Unsigned Edge Case with Sign-Extended Immediate
    # Logic: 0 < 0xFFFFFFFF (-1 sign extended) = 1
    # -----------------------------------------------------------------
test_sltiu_3:
    li      t1, 0
    sltiu   t3, t1, -1          # -1 is 0xFFFFFFFF in unsigned
    li      t4, 1
    beq     t3, t4, pass_sltiu
    j       Fail_Sltiu_3

pass_sltiu:
    j return_sltiu_test

# --- Failure Handlers ---
Fail_Sltiu_1:
    li gp, 1421
    j fail
Fail_Sltiu_2:
    li gp, 1422
    j fail
Fail_Sltiu_3:
    li gp, 1423
    j fail
