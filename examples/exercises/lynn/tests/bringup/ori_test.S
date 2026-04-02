.extern return_ori_test
.extern fail

    .section .text.init
    .globl ori_test
    .type  ori_test, @function

ori_test:
    ori_test1:
        # -----------------------------------------------------------------
        # Test 1: Basic Bitwise OR
        # Pattern: 11110000 (0xF0) | 00001111 (0x0F) = 11111111 (0xFF)
        # -----------------------------------------------------------------
        li      t0, 0xF0

        # Target Instruction:
        ori     t1, t0, 0x0F    # t1 = t0 | 15

        li      t2, 0xFF        # Expected: 255 (0xFF)

        # Verify
        beq     t1, t2, ori_test2
        j       Fail_Ori_1

    ori_test2:
        # -----------------------------------------------------------------
        # Test 2: Sign Extension Check
        # Spec says: x[rd] = x[rs1] | sext(immediate)
        # We test with Immediate = -1 (0xFFF).
        # It must become 0xFFFFFFFF.
        # -----------------------------------------------------------------
        li      t0, 0

        # Target Instruction:
        # If hardware correctly sign-extends, t1 becomes 0xFFFFFFFF (-1)
        # If hardware incorrectly zero-extends, t1 becomes 0x00000FFF (4095)
        ori     t1, t0, -1

        # Verification Trick (No 'lui' allowed):
        # We add 1 to the result.
        # -1 + 1 = 0.
        # 4095 + 1 = 4096.
        addi    t2, t1, 1

        li      t3, 0

        # Verify: Result must be 0
        beq     t2, t3, pass
        j       Fail_Ori_2

    pass:
        j       return_ori_test

Fail_Ori_1:
    li      gp, 821             # Error: ORI Basic logic failed
    j       fail

Fail_Ori_2:
    li      gp, 822             # Error: ORI Sign-Extension failed
    j       fail
