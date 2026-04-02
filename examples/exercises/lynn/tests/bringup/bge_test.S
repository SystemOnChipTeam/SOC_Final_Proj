// Tests for BGE and BGEU
// Constraints: Only li, bge, bgeu, j.

.extern return_bge_test
.extern fail
.section .text.init
.globl bge_test
.type bge_test, @function

bge_test:
    # -----------------------------------------------------------------
    # Test 1: BGE (Signed) - Greater Than
    # Logic: 1 >= -1 (Should Branch)
    # -----------------------------------------------------------------
test_bge_1:
    li      t1, 1
    li      t2, -1
    bge     t1, t2, test_bge_2
    j       Fail_Bge_1

    # -----------------------------------------------------------------
    # Test 2: BGE (Signed) - Equal
    # Logic: -5 >= -5 (Should Branch)
    # -----------------------------------------------------------------
test_bge_2:
    li      t1, -5
    li      t2, -5
    bge     t1, t2, test_bge_3
    j       Fail_Bge_2

    # -----------------------------------------------------------------
    # Test 3: BGE (Signed) - False Condition
    # Logic: -1 >= 1 is False (Should NOT Branch)
    # -----------------------------------------------------------------
test_bge_3:
    li      t1, -1
    li      t2, 1
    bge     t1, t2, Fail_Bge_3
    j       test_bge_4

    # -----------------------------------------------------------------
    # Test 4: BGEU (Unsigned) - True Condition (Tricky)
    # Logic: -1 (0xFFFFFFFF) >= 1 is True in unsigned math!
    # -----------------------------------------------------------------
test_bge_4:
    li      t1, -1
    li      t2, 1
    bgeu    t1, t2, pass_bge
    j       Fail_Bge_4

pass_bge:
    j return_bge_test

# --- Failure Handlers ---
Fail_Bge_1:
    li gp, 2201
    j fail
Fail_Bge_2:
    li gp, 2202
    j fail
Fail_Bge_3:
    li gp, 2203
    j fail
Fail_Bge_4:
    li gp, 2204
    j fail
