.extern return_slt_test
.extern fail

    .section .text.init
    .globl slt_test
    .type  slt_test, @function

slt_test:
    # -----------------------------------------------------------------
    # Test 1: 10 < 20 (True)
    # -----------------------------------------------------------------
    li      t0, 10
    li      t1, 20

    # Target Instruction
    slt     t2, t0, t1      # t2 should become 1

    # Verification
    li      t3, 1           # Expected result

    # CRITICAL MOMENT:
    # This BEQ should jump forward exactly 8 bytes to 'pass'
    # If it jumps to 0x8000143X, check your B-Type Immediate Gen.
    beq     t2, t3, pass

    # If we didn't jump, we failed.
    j       fail_slt

pass:
    j       return_slt_test

fail_slt:
    li      gp, 510         # Error code for SLT failure
    j       fail
