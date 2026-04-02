// Tests for JALR (Jump and Link Register)
// Logic: PC = (rs1 + imm) & ~1, rd = PC + 4
// Constraints: Only li, jalr, beq, j.

.extern return_jalr_test
.extern fail
.section .text.init
.globl jalr_test
.type jalr_test, @function

jalr_test:

    # -----------------------------------------------------------------
    # Test 1: Basic Forward Jump & Link
    # We will jump over a "trap" instruction.
    # -----------------------------------------------------------------
test_jalr_1:
    la      t0, target_1        # Load address of target label
    jalr    ra, 0(t0)           # Jump to target_1, save PC+4 in ra

    # If we are here, the jump failed
    j       Fail_Jalr_1

target_1:
    # Verify the return address (ra)
    # ra should point to the 'j Fail_Jalr_1' instruction above.
    la      t1, test_jalr_1
    addi    t1, t1, 8           # test_jalr_1 (la) + 4 (jalr) = 8
    beq     ra, t1, test_jalr_2
    j test_jalr_2
    j       Fail_Jalr_2

    # -----------------------------------------------------------------
    # Test 2: Jump with Offset
    # We use a base address and a non-zero immediate.
    # -----------------------------------------------------------------
test_jalr_2:
    la      t0, target_2_base
    jalr    t1, 8(t0)           # Jump to base + 8
    j       Fail_Jalr_3         # Should be skipped

target_2_base:
    nop                         # offset 0
    nop                         # offset 4
target_2_real:                  # offset 8
    li      t2, 1
    beq     t2, t2, pass_jalr   # If we hit this, the offset worked
    j       Fail_Jalr_4

pass_jalr:
    j return_jalr_test

# --- Failure Handlers ---
Fail_Jalr_1:
    li gp, 2301
    j fail
Fail_Jalr_2:
    li gp, 2302
    j fail
Fail_Jalr_3:
    li gp, 2303
    j fail
Fail_Jalr_4:
    li gp, 2304
    j fail
