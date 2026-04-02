// Tests for LH and LHU (Load Halfword / Load Halfword Unsigned)
// Constraints: Only li, lw, sw, lh, lhu, beq, j, lui, addi.

.extern return_lh_test
.extern fail
.section .text.init
.globl lh_test
.type lh_test, @function

lh_test:
    # Set base address to 0x8000010C
    lui     s0, 0x80000
    addi    s0, s0, 0x10C

    # Write test pattern to memory: 0x80007FFF
    # Upper Half (Offset 2): 0x8000 (Negative, MSB is 1)
    # Lower Half (Offset 0): 0x7FFF (Positive max, MSB is 0)
    lui     t1, 0x80008         # 0x80008000
    addi    t1, t1, -1          # 0x80007FFF
    sw      t1, 0(s0)

    # -----------------------------------------------------------------
    # Test 1: LH on Positive Halfword (Lower Half)
    # Logic: 0x7FFF sign-extended is 0x00007FFF
    # -----------------------------------------------------------------
test_lh_1:
    lh      t2, 0(s0)           # Load halfword at offset 0
    li      t3, 0x7FFF
    beq     t2, t3, test_lh_2
    j       Fail_Lh_1

    # -----------------------------------------------------------------
    # Test 2: LH on Negative Halfword (Upper Half)
    # Logic: 0x8000 sign-extended is 0xFFFF8000
    # -----------------------------------------------------------------
test_lh_2:
    lh      t2, 2(s0)           # Load halfword at offset 2
    lui     t3, 0xFFFF8         # 0xFFFF8000
    beq     t2, t3, test_lh_3
    j       Fail_Lh_2

    # -----------------------------------------------------------------
    # Test 3: LHU on Negative Halfword (Upper Half)
    # Logic: 0x8000 zero-extended should be exactly 0x00008000
    # -----------------------------------------------------------------
test_lh_3:
    lhu     t2, 2(s0)           # Load half unsigned at offset 2
    li      t3, 0x8000          # 0x00008000
    beq     t2, t3, pass_lh
    j       Fail_Lh_3

pass_lh:
    j return_lh_test

# --- Failure Handlers ---
Fail_Lh_1:
    li gp, 1901
    j fail
Fail_Lh_2:
    li gp, 1902
    j fail
Fail_Lh_3:
    li gp, 1903
    j fail
