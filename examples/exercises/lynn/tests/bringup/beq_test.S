.extern return_beq_test
.extern fail

    .section .text.init
    .globl beq_test
    .type  beq_test, @function

beq_test:
    beq_test1:
        # -----------------------------------------------------------------
        # Test 1: Forward Branch (Equal)
        # -----------------------------------------------------------------
        li      t0, 100
        li      t1, 100

        # Should jump to beq_test2
        beq     t0, t1, beq_test2

        # If it doesn't jump, it's a failure
        j       Fail_Beq_1

    beq_test2:
        # -----------------------------------------------------------------
        # Test 2: Fall-through (Not Equal)
        # -----------------------------------------------------------------
        li      t0, 100
        li      t1, 200

        # Should NOT jump
        beq     t0, t1, Fail_Beq_2

        # PC should naturally arrive here
        j       beq_test3

    beq_test3:
        # -----------------------------------------------------------------
        # Test 3: Backward Branch
        # -----------------------------------------------------------------
        li      t0, 5
        li      t1, 5

        # Jump forward to the actual check
        j       back_target_check

    back_target:
        # We reached the backward jump successfully!
        j       pass

    back_target_check:
        # This is the backward jump instruction
        beq     t0, t1, back_target

        # If we didn't jump back, it failed
        j       Fail_Beq_3

    pass:
        j       return_beq_test

Fail_Beq_1:
    li      gp, 1001            # Forward branch failed
    j       fail

Fail_Beq_2:
    li      gp, 1002            # Incorrectly branched when not equal
    j       fail

Fail_Beq_3:
    li      gp, 1003            # Backward branch failed
    j       fail
