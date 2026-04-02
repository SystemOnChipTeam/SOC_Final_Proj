// lw_test.S
// Tests for LW (Load Word)
// Format: lw rd, offset(rs1)
//
// Constraints: No LUI, AUIPC, or STORE instructions.
// Strategy: Use JAL to get a pointer to embedded data in the code segment.

.extern return_lw_test
.extern fail
.section .text.init
.globl lw_test
.type lw_test, @function

lw_test:

    # -----------------------------------------------------------------
    # Data Setup (The "Jump-and-Link" Trick)
    # -----------------------------------------------------------------
    # We place data right inside the instruction stream.
    # 'jal t0, begin_tests' does two things:
    # 1. Jumps to 'begin_tests'.
    # 2. Stores (PC + 4) into t0.
    # Since the data is located exactly at (PC + 4), t0 becomes our
    # base pointer to 'test_values'.

    jal t0, begin_tests

    # Ensure data is 4-byte aligned so we don't trigger alignment faults
    .balign 4

test_values:
    .word 42            # Offset 0:  Small positive
    .word -123          # Offset 4:  Small negative
    .word 2024          # Offset 8:  Large positive (fits in 12-bit)
    .word -2000         # Offset 12: Large negative

begin_tests:

    # -----------------------------------------------------------------
    # Test 1: Basic Load (Zero Offset)
    # Logic: Load word at t0 + 0. Expect 42.
    # -----------------------------------------------------------------
test1:
    lw      t1, 0(t0)
    li      t2, 42
    beq     t1, t2, test2
    j       Fail_Lw_1

    # -----------------------------------------------------------------
    # Test 2: Positive Immediate Offset
    # Logic: Load word at t0 + 4. Expect -123.
    # -----------------------------------------------------------------
test2:
    lw      t1, 4(t0)
    li      t2, -123        # Fits in 12-bit immediate
    beq     t1, t2, test3
    j       Fail_Lw_2

    # -----------------------------------------------------------------
    # Test 3: Larger Positive Offset
    # Logic: Load word at t0 + 8. Expect 2024.
    # -----------------------------------------------------------------
test3:
    lw      t1, 8(t0)
    li      t2, 2024
    beq     t1, t2, test4
    j       Fail_Lw_3

    # -----------------------------------------------------------------
    # Test 4: Negative Immediate Offset
    # Logic: Move pointer forward, then look backwards.
    # -----------------------------------------------------------------
test4:
    addi    t3, t0, 12      # t3 points to the last word (-2000)
    lw      t1, -4(t3)      # Load t3 - 4 (Should be 2024 again)

    li      t2, 2024
    beq     t1, t2, test5
    j       Fail_Lw_4

    # -----------------------------------------------------------------
    # Test 5: Destructive Load (Loading into the base register)
    # Logic: x[rd] = M[ x[rd] + offset ]
    # We load the first value (42) into the pointer register itself.
    # -----------------------------------------------------------------
test5:
    # t0 still points to start of data (value 42)
    lw      t0, 0(t0)       # t0 should become 42
    li      t2, 42
    beq     t0, t2, pass
    j       Fail_Lw_5

pass:
    j return_lw_test

# -----------------------------------------------------------------
# Failure Handlers (600 Range)
# -----------------------------------------------------------------
Fail_Lw_1:
    li gp, 601
    j fail
Fail_Lw_2:
    li gp, 602
    j fail
Fail_Lw_3:
    li gp, 603
    j fail
Fail_Lw_4:
    li gp, 604
    j fail
Fail_Lw_5:
    li gp, 605
    j fail
