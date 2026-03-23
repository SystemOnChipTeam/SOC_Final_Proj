.extern return_sra_test
.extern fail

    .section .text.init
    .globl sra_test
    .type  sra_test, @function

sra_test:

    # Test 1: Basic positive shift
test1:
    li   t0, 16
    li   t1, 2
    sra  t2, t0, t1
    li   t3, 4
    beq  t2, t3, test2
    j Fail_SRA_1

    # Test 2: Shift by 0
test2:
    li   t0, -123
    li   t1, 0
    sra  t2, t0, t1
    li   t3, -123
    beq  t2, t3, test3
    j Fail_SRA_2

    # Test 3: Negative number sign extension
test3:
    li   t0, -4              # 0xFFFFFFFC
    li   t1, 1
    sra  t2, t0, t1
    li   t3, -2              # 0xFFFFFFFE
    beq  t2, t3, test4
    j Fail_SRA_3

    # Test 4: Large negative shift
test4:
    li   t0, 0x80000000      # Most negative number
    li   t1, 31
    sra  t2, t0, t1
    li   t3, -1              # All 1s
    beq  t2, t3, test5
    j Fail_SRA_4

    # Test 5: Large positive shift
test5:
    li   t0, 0x7FFFFFFF
    li   t1, 31
    sra  t2, t0, t1
    li   t3, 0
    beq  t2, t3, test6
    j Fail_SRA_5

    # Test 6: srai basic
test6:
    li   t0, -32
    srai t2, t0, 3
    li   t3, -4
    beq  t2, t3, test7
    j Fail_SRA_6

    # Test 7: srai shift by 0
test7:
    li   t0, 500
    srai t2, t0, 0
    li   t3, 500
    beq  t2, t3, test8
    j Fail_SRA_7

    # Test 8: srai sign extension edge
test8:
    li   t0, -1              # 0xFFFFFFFF
    srai t2, t0, 5
    li   t3, -1              # Should remain all 1s
    beq  t2, t3, test9
    j Fail_SRA_8

    # Test 9: Alternating bits negative
test9:
    li   t0, 0xAAAAAAAA      # Negative number
    li   t1, 1
    sra  t2, t0, t1
    li   t3, 0xD5555555
    beq  t2, t3, test10
    j Fail_SRA_9

    # Test 10: Shift amount masking (33 → 1 in RV32)
test10:
    li   t0, -8
    li   t1, 33              # 33 mod 32 = 1
    sra  t2, t0, t1
    li   t3, -4
    beq  t2, t3, pass
    j Fail_SRA_10


pass:
    j return_sra_test


Fail_SRA_1:
    li   gp, 421
    j    fail

Fail_SRA_2:
    li   gp, 422
    j    fail

Fail_SRA_3:
    li   gp, 423
    j    fail

Fail_SRA_4:
    li   gp, 424
    j    fail

Fail_SRA_5:
    li   gp, 425
    j    fail

Fail_SRA_6:
    li   gp, 426
    j    fail

Fail_SRA_7:
    li   gp, 427
    j    fail

Fail_SRA_8:
    li   gp, 428
    j    fail

Fail_SRA_9:
    li   gp, 429
    j    fail

Fail_SRA_10:
    li   gp, 430
    j    fail
