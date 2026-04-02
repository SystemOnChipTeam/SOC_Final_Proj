.extern return_sltu_test
.extern fail

    .section .text.init
    .globl sltu_test
    .type  sltu_test, @function

sltu_test:

    # Test 1: Basic unsigned less than
test1:
    li   t0, 3
    li   t1, 5
    sltu t2, t0, t1
    li   t3, 1
    beq  t2, t3, test2
    j Fail_SLTU_1

    # Test 2: Not less than
test2:
    li   t0, 10
    li   t1, 4
    sltu t2, t0, t1
    li   t3, 0
    beq  t2, t3, test3
    j Fail_SLTU_2

    # Test 3: Equal values
test3:
    li   t0, 7
    li   t1, 7
    sltu t2, t0, t1
    li   t3, 0
    beq  t2, t3, test4
    j Fail_SLTU_3

    # Test 4: 0 < max unsigned
test4:
    li   t0, 0
    li   t1, -1              # 0xFFFFFFFF (largest unsigned)
    sltu t2, t0, t1
    li   t3, 1
    beq  t2, t3, test5
    j Fail_SLTU_4

    # Test 5: max unsigned < 0 (should be false)
test5:
    li   t0, -1              # 0xFFFFFFFF
    li   t1, 0
    sltu t2, t0, t1
    li   t3, 0
    beq  t2, t3, test6
    j Fail_SLTU_5

    # Test 6: sltiu basic
test6:
    li    t0, 2
    sltiu t2, t0, 5
    li    t3, 1
    beq   t2, t3, test7
    j Fail_SLTU_6

    # Test 7: sltiu not less
test7:
    li    t0, 8
    sltiu t2, t0, 3
    li    t3, 0
    beq   t2, t3, test8
    j Fail_SLTU_7

    # Test 8: sltiu equal
test8:
    li    t0, 12
    sltiu t2, t0, 12
    li    t3, 0
    beq   t2, t3, test9
    j Fail_SLTU_8

    # Test 9: sltiu with negative immediate
    # Immediate is sign-extended before unsigned compare
test9:
    li    t0, 0
    sltiu t2, t0, -1         # -1 → 0xFFFFFFFF
    li    t3, 1
    beq   t2, t3, test10
    j Fail_SLTU_9

    # Test 10: Boundary case
test10:
    li   t0, 0x7FFFFFFF
    li   t1, 0x80000000
    sltu t2, t0, t1
    li   t3, 1
    beq  t2, t3, pass
    j Fail_SLTU_10


pass:
    j return_sltu_test


Fail_SLTU_1:
    li   gp, 431
    j    fail

Fail_SLTU_2:
    li   gp, 432
    j    fail

Fail_SLTU_3:
    li   gp, 433
    j    fail

Fail_SLTU_4:
    li   gp, 434
    j    fail

Fail_SLTU_5:
    li   gp, 435
    j    fail

Fail_SLTU_6:
    li   gp, 436
    j    fail

Fail_SLTU_7:
    li   gp, 437
    j    fail

Fail_SLTU_8:
    li   gp, 438
    j    fail

Fail_SLTU_9:
    li   gp, 439
    j    fail

Fail_SLTU_10:
    li   gp, 440
    j    fail
