// Tests for BNE
// Constraints: Only li, beq, bne, j.

.extern return_bne_test
.extern fail
.section .text.init
.globl bne_test
.type bne_test, @function

bne_test:
    # -----------------------------------------------------------------
    # Test 1: Not Equal (Should Branch)
    # -----------------------------------------------------------------
test_bne_1:
    li      t1, 1
    li      t2, 2
    bne     t1, t2, test_bne_2  # 1 != 2, so it MUST branch to test_bne_2
    j       Fail_Bne_1          # If it falls through, it failed

    # -----------------------------------------------------------------
    # Test 2: Equal (Should NOT Branch)
    # -----------------------------------------------------------------
test_bne_2:
    li      t1, 5
    li      t2, 5
    bne     t1, t2, Fail_Bne_2  # 5 == 5, so it MUST NOT branch
    j       pass_bne            # It should fall through to here

pass_bne:
    j return_bne_test

# --- Failure Handlers ---
Fail_Bne_1:
    li gp, 2001
    j fail
Fail_Bne_2:
    li gp, 2002
    j fail
