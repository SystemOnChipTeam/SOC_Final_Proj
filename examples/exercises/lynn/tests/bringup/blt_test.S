// Tests for BLT and BLTU
// Constraints: Only li, bne, blt, bltu, j.

.extern return_blt_test
.extern fail
.section .text.init
.globl blt_test
.type blt_test, @function

blt_test:
    # -----------------------------------------------------------------
    # Test 1: BLT (Signed) - True Condition
    # Logic: -1 < 1 (Should Branch)
    # -----------------------------------------------------------------
test_blt_1:
    li      t1, -1
    li      t2, 1
    blt     t1, t2, test_blt_2
    j       Fail_Blt_1

    # -----------------------------------------------------------------
    # Test 2: BLT (Signed) - False Condition
    # Logic: 1 < -1 is False (Should NOT Branch)
    # -----------------------------------------------------------------
test_blt_2:
    li      t1, 1
    li      t2, -1
    blt     t1, t2, Fail_Blt_2
    j       test_blt_3

    # -----------------------------------------------------------------
    # Test 3: BLTU (Unsigned) - True Condition
    # Logic: 1 < 2 (Should Branch)
    # -----------------------------------------------------------------
test_blt_3:
    li      t1, 1
    li      t2, 2
    bltu    t1, t2, test_blt_4
    j       Fail_Blt_3

    # -----------------------------------------------------------------
    # Test 4: BLTU (Unsigned) - False Condition (The Tricky One)
    # Logic: -1 (0xFFFFFFFF) < 1 is False in unsigned math!
    # -----------------------------------------------------------------
test_blt_4:
    li      t1, -1              # 0xFFFFFFFF
    li      t2, 1               # 0x00000001
    bltu    t1, t2, Fail_Blt_4  # Must NOT branch!
    j       pass_blt

pass_blt:
    j return_blt_test

# --- Failure Handlers ---
Fail_Blt_1:
    li gp, 2101
    j fail
Fail_Blt_2:
    li gp, 2102
    j fail
Fail_Blt_3:
    li gp, 2103
    j fail
Fail_Blt_4:
    li gp, 2104
    j fail
