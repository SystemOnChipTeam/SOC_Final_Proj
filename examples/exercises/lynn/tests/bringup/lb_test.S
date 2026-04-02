// Tests for LB and LBU (Load Byte / Load Byte Unsigned)
// Constraints: Only li, lw, sw, lb, lbu, beq, j, lui, addi.

.extern return_lb_test
.extern fail
.section .text.init
.globl lb_test
.type lb_test, @function

lb_test:
    # Set base address to 0x80000104
    lui     s0, 0x80000         # s0 = 0x80000000
    addi    s0, s0, 0x104       # s0 = 0x80000104 (Next word over)

    # Write test pattern to memory: 0x807F00FF
    lui     t1, 0x807F0
    addi    t1, t1, 0x0FF
    sw      t1, 0(s0)

    # -----------------------------------------------------------------
    # Test 1: LB on Negative Byte (Byte 0)
    # Logic: 0xFF sign-extended to 32-bit should be 0xFFFFFFFF (-1)
    # -----------------------------------------------------------------
test_lb_1:
    lb      t2, 0(s0)           # Load byte 0 (0xFF)
    li      t3, -1              # Expected: 0xFFFFFFFF
    beq     t2, t3, test_lb_2
    j       Fail_Lb_1

    # -----------------------------------------------------------------
    # Test 2: LBU on Negative Byte (Byte 0)
    # Logic: 0xFF zero-extended should be exactly 0x000000FF (255)
    # -----------------------------------------------------------------
test_lb_2:
    lbu     t2, 0(s0)
    li      t3, 0xFF            # Expected: 0x000000FF
    beq     t2, t3, test_lb_3
    j       Fail_Lb_2

    # -----------------------------------------------------------------
    # Test 3: LB on Zero Byte (Byte 1)
    # Logic: 0x00 sign-extended is just 0
    # -----------------------------------------------------------------
test_lb_3:
    lb      t2, 1(s0)           # Load byte 1 (0x00)
    li      t3, 0
    beq     t2, t3, test_lb_4
    j       Fail_Lb_3

    # -----------------------------------------------------------------
    # Test 4: LB on Positive Byte (Byte 2)
    # Logic: 0x7F sign-extended is 0x0000007F (Sign bit is 0, so no FFs)
    # -----------------------------------------------------------------
test_lb_4:
    lb      t2, 2(s0)           # Load byte 2 (0x7F)
    li      t3, 0x7F
    beq     t2, t3, test_lb_5
    j       Fail_Lb_4

    # -----------------------------------------------------------------
    # Test 5: LB on MSB Negative Byte (Byte 3)
    # Logic: 0x80 sign-extended is 0xFFFFFF80
    # -----------------------------------------------------------------
test_lb_5:
    lb      t2, 3(s0)           # Load byte 3 (0x80)
    li      t3, -128            # -128 in decimal is 0xFFFFFF80
    beq     t2, t3, pass_lb
    j       Fail_Lb_5

pass_lb:
    j return_lb_test

# --- Failure Handlers ---
Fail_Lb_1:
    li gp, 1701
    j fail
Fail_Lb_2:
    li gp, 1702
    j fail
Fail_Lb_3:
    li gp, 1703
    j fail
Fail_Lb_4:
    li gp, 1704
    j fail
Fail_Lb_5:
    li gp, 1705
    j fail
