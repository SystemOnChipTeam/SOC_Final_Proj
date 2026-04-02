// C Runtime entry point
// James Kaden Cassidy
// kacassidy@hmc.edu
// 1/21/2026

.extern return_slti_test
.extern fail

    .section .text.init
    .globl slti_test
    .type  slti_test, @function

slti_test:
    test1:
        # -----------------------------------------------------------------
        # Test 1: True Condition (10 < 20)
        # -----------------------------------------------------------------
        li      t0, 10

        # Target Instruction:
        # Compares Register t0 (10) vs Immediate (20)
        slti    t1, t0, 20      # t1 = (10 < 20) ? 1 : 0

        li      t2, 1           # Expected Result: 1
        beq     t1, t2, test2   # If Equal, pass to next
        j       Fail_Slti_1

    test2:
        # -----------------------------------------------------------------
        # Test 2: False Condition (20 < 10)
        # -----------------------------------------------------------------
        li      t0, 20

        # Target Instruction:
        slti    t1, t0, 10      # t1 = (20 < 10) ? 1 : 0

        li      t2, 0           # Expected Result: 0
        beq     t1, t2, test3
        j       Fail_Slti_2

    test3:
        # -----------------------------------------------------------------
        # Test 3: Equality (15 < 15) -> False
        # -----------------------------------------------------------------
        li      t0, 15

        # Target Instruction:
        slti    t1, t0, 15      # t1 = (15 < 15) ? 1 : 0

        li      t2, 0           # Expected Result: 0
        beq     t1, t2, test4
        j       Fail_Slti_3

    test4:
        # -----------------------------------------------------------------
        # Test 4: Negative Logic (-5 < 5) -> True
        # -----------------------------------------------------------------
        # This tests if your Immediate Generator correctly Sign-Extends.
        # If your processor treats -5 as a large unsigned number, this fails.
        li      t0, -5          # t0 = 0xFFFFFFFB

        slti    t1, t0, 5       # t1 = (-5 < 5) ? 1 : 0

        li      t2, 1           # Expected Result: 1
        beq     t1, t2, pass
        j       Fail_Slti_4

    pass:
        j       return_slti_test

Fail_Slti_1:
    li      gp, 811             # Error: SLTI True case failed
    j       fail

Fail_Slti_2:
    li      gp, 812             # Error: SLTI False case failed
    j       fail

Fail_Slti_3:
    li      gp, 813             # Error: SLTI Equality case failed
    j       fail

Fail_Slti_4:
    li      gp, 814             # Error: SLTI Negative case failed
    j       fail
