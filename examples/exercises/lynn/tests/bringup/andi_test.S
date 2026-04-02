.extern return_andi_test
.extern fail

    .section .text.init
    .globl andi_test
    .type  andi_test, @function

andi_test:
    andi_test1:
        # -----------------------------------------------------------------
        # Test 1: Basic Masking
        # Pattern: 11111111 (0xFF) & 00001111 (0x0F) = 00001111 (0x0F)
        # -----------------------------------------------------------------
        li      t0, 0xFF        # Load 255

        # Target Instruction:
        andi    t1, t0, 0x0F    # t1 = t0 & 15

        li      t2, 0x0F        # Expected result (15)

        # Verify
        beq     t1, t2, andi_test2
        j       Fail_Andi_1

    andi_test2:
        # -----------------------------------------------------------------
        # Test 2: Sign Extension Check
        # Spec says: x[rd] = x[rs1] & sext(immediate)
        # We test with Immediate = -1 (12 bits = 0xFFF).
        # It must be sign-extended to 32 bits (0xFFFFFFFF).
        # -----------------------------------------------------------------
        li      t0, -1          # t0 = 0xFFFFFFFF

        # Target Instruction:
        # If hardware correctly sign-extends, t1 becomes 0xFFFFFFFF (-1)
        # If hardware incorrectly zero-extends, t1 becomes 0x00000FFF (4095)
        andi    t1, t0, -1

        # Verification Trick (No 'lui' allowed):
        # We add 1 to the result.
        # -1 + 1 = 0.
        # 4095 + 1 = 4096.
        addi    t2, t1, 1

        li      t3, 0

        # Verify: Result must be 0
        beq     t2, t3, pass
        j       Fail_Andi_2

    pass:
        j       return_andi_test

Fail_Andi_1:
    li      gp, 211             # Error: ANDI Basic logic failed
    j       fail

Fail_Andi_2:
    li      gp, 212             # Error: ANDI Sign-Extension failed
    j       fail
