// Tests for SRA (Shift Right Arithmetic)
// Logic: rd = rs1 >>> rs2[4:0] (Sign-extend)
// Constraints: Only addi, beq, j, lui, li, and sra.

.extern return_sra_test
.extern fail
.section .text.init
.globl sra_test
.type sra_test, @function

sra_test:

    # -----------------------------------------------------------------
    # Test 1: Arithmetic Shift on Positive Number
    # Logic: 16 >>> 2 = 4 (Should behave exactly like SRL here)
    # -----------------------------------------------------------------
test_sra_1:
    li      t1, 16
    li      t2, 2
    sra     t3, t1, t2
    li      t4, 4
    beq     t3, t4, test_sra_2
    j       Fail_Sra_1

    # -----------------------------------------------------------------
    # Test 2: Arithmetic Shift on Negative Number
    # Logic: -16 >>> 2 = -4 (Preserves the negative sign)
    # -----------------------------------------------------------------
test_sra_2:
    li      t1, -16             # 0xFFFFFFF0
    li      t2, 2
    sra     t3, t1, t2          # 0xFFFFFFFC (-4)
    li      t4, -4
    beq     t3, t4, test_sra_3
    j       Fail_Sra_2

    # -----------------------------------------------------------------
    # Test 3: Full Sign Extension Check
    # Logic: 0x80000000 >>> 31 = 0xFFFFFFFF (-1)
    # -----------------------------------------------------------------
test_sra_3:
    lui     t1, 0x80000         # 0x80000000
    li      t2, 31
    sra     t3, t1, t2
    li      t4, -1              # 0xFFFFFFFF
    beq     t3, t4, pass_sra
    j       Fail_Sra_3

pass_sra:
    j return_sra_test

# --- Failure Handlers ---
Fail_Sra_1:
    li gp, 1451
    j fail
Fail_Sra_2:
    li gp, 1452
    j fail
Fail_Sra_3:
    li gp, 1453
    j fail
