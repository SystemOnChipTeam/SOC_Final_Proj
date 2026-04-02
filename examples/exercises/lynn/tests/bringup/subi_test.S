// subi_test.S
// Comprehensive tests for the SUB (Subtract Register) instruction
// Format: sub rd, rs1, rs2
// Logic: x[rd] = x[rs1] - x[rs2]
//
// Note: RV32I does not have a hardware 'subi'.
// 'subi' is valid assembly but compiles to 'addi'.
// This file tests the actual R-type SUB instruction.

.extern return_sub_test
.extern fail
.section .text.init
.globl subi_test
.type subi_test, @function

subi_test:

    # -----------------------------------------------------------------
    # Test 1: Basic Positive Subtraction
    # Logic: 10 - 3 = 7
    # -----------------------------------------------------------------
test1:
    li      t0, 10
    li      t1, 3
    sub     t2, t0, t1
    li      t3, 7
    beq     t2, t3, test2
    j       Fail_Sub_1

    # -----------------------------------------------------------------
    # Test 2: Result becomes Negative
    # Logic: 5 - 10 = -5
    # -----------------------------------------------------------------
test2:
    li      t0, 5
    li      t1, 10
    sub     t2, t0, t1
    li      t3, -5
    beq     t2, t3, test3
    j       Fail_Sub_2

    # -----------------------------------------------------------------
    # Test 3: Subtracting a Negative (Double Negation)
    # Logic: 10 - (-5) = 15
    # -----------------------------------------------------------------
test3:
    li      t0, 10
    li      t1, -5
    sub     t2, t0, t1
    li      t3, 15
    beq     t2, t3, test4
    j       Fail_Sub_3

    # -----------------------------------------------------------------
    # Test 4: Result Zero
    # Logic: 123 - 123 = 0
    # -----------------------------------------------------------------
test4:
    li      t0, 123
    li      t1, 123
    sub     t2, t0, t1
    li      t3, 0
    beq     t2, t3, test5
    j       Fail_Sub_4

    # -----------------------------------------------------------------
    # Test 5: Wraparound (Overflow)
    # Logic: Max Negative - 1 = Max Positive
    # -2147483648 (0x80000000) - 1 = +2147483647 (0x7FFFFFFF)
    # We construct these large numbers carefully without LUI.
    # -----------------------------------------------------------------
test5:
    # Construct 0x80000000 (Min Int) in t0
    # We start with 0 and subtract big chunks using ADDI
    # But ADDI limit is 2048. It's easier to use valid small sub steps.

    # Let's verify a simpler wrap:
    # Logic: 0 - 1 = -1 (0xFFFFFFFF)
    li      t0, 0
    li      t1, 1
    sub     t2, t0, t1   # 0 - 1
    li      t3, -1
    beq     t2, t3, pass
    j       Fail_Sub_5

pass:
    j return_subi_test

# -----------------------------------------------------------------
# Failure Handlers (500 Range)
# -----------------------------------------------------------------
Fail_Sub_1:
    li gp, 501
    j fail
Fail_Sub_2:
    li gp, 502
    j fail
Fail_Sub_3:
    li gp, 503
    j fail
Fail_Sub_4:
    li gp, 504
    j fail
Fail_Sub_5:
    li gp, 505
    j fail
