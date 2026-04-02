// addi_test.S
// Tests for ADDI (Add Immediate)
// Constraints: No LUI, No BNE, No Shifts.
// Uses only: addi, beq, j (jal), and registers.

.extern return_addi_test
.extern fail
.section .text.init
.globl addi_test
.type addi_test, @function

addi_test:

    # -----------------------------------------------------------------
    # Test 1: Basic Positive Addition
    # Logic: 5 + 7 = 12
    # -----------------------------------------------------------------
test1:
    li      t0, 5           # li is safe here (5 fits in 12 bits)
    addi    t1, t0, 7
    li      t2, 12          # Safe
    beq     t1, t2, test2
    j       Fail_Addi_1

    # -----------------------------------------------------------------
    # Test 2: Negative Immediate (Sign Extension Check)
    # Logic: 20 + (-5) = 15
    # -----------------------------------------------------------------
test2:
    li      t0, 20
    addi    t1, t0, -5      # Encoded as 12-bit signed immediate
    li      t2, 15
    beq     t1, t2, test3
    j       Fail_Addi_2

    # -----------------------------------------------------------------
    # Test 3: Zero Immediate (Identity / MV)
    # Logic: 100 + 0 = 100
    # -----------------------------------------------------------------
test3:
    li      t0, 100
    addi    t1, t0, 0
    beq     t1, t0, test4
    j       Fail_Addi_3

    # -----------------------------------------------------------------
    # Test 4: Max Positive Boundary & Overflow into 13th bit
    # Logic: 10 + 2047 = 2057
    # Constraint: Cannot use 'li t2, 2057' because it generates LUI.
    # -----------------------------------------------------------------
test4:
    li      t0, 10
    addi    t1, t0, 2047    # t1 should be 2057

    # Construct expected value (2057) using valid steps:
    li      t2, 1000        # Safe (fits in 12 bits)
    addi    t2, t2, 1057    # 1000 + 1057 = 2057

    beq     t1, t2, test5
    j       Fail_Addi_4

    # -----------------------------------------------------------------
    # Test 5: Min Negative Boundary
    # Logic: 10 + (-2048) = -2038
    # Constraint: Cannot use 'li' for -2038 if the assembler tries to be smart.
    # -----------------------------------------------------------------
test5:
    li      t0, 10
    addi    t1, t0, -2048   # t1 should be -2038

    # Construct expected value (-2038):
    li      t2, -1000       # Safe
    addi    t2, t2, -1038   # -1000 + (-1038) = -2038

    beq     t1, t2, pass
    j       Fail_Addi_5

pass:
    j return_addi_test

# -----------------------------------------------------------------
# Failure Handlers
# -----------------------------------------------------------------
Fail_Addi_1:
    li gp, 401
    j fail
Fail_Addi_2:
    li gp, 402
    j fail
Fail_Addi_3:
    li gp, 403
    j fail
Fail_Addi_4:
    li gp, 404
    j fail
Fail_Addi_5:
    li gp, 405
    j fail
