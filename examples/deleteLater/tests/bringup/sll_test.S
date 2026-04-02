.extern return_sll_test
.extern fail

    .section .text.init
    .globl sll_test
    .type  sll_test, @function

sll_test:

    # Test 1: Basic sll
test1:
    li   t0, 3
    li   t1, 2
    sll  t2, t0, t1
    li   t3, 12
    beq  t2, t3, test2
    j Fail_SLL_1

    # Test 2: Shift by 0
test2:
    li   t0, 15
    li   t1, 0
    sll  t2, t0, t1
    li   t3, 15
    beq  t2, t3, test5
    j Fail_SLL_2

    # Test 3: Shift into MSB
test3:
    li   t0, 1
    li   t1, 31
    sll  t2, t0, t1
    li   t3, 0x80000000
    beq  t2, t3, test4
    j Fail_SLL_3

    # Test 4: Overflow out of range
test4:
    li   t0, 0x80000000
    li   t1, 1
    sll  t2, t0, t1
    li   t3, 0
    beq  t2, t3, test5
    j Fail_SLL_4

    # Test 5: Negative number
test5:
    li   t0, -4
    li   t1, 1
    sll  t2, t0, t1
    li   t3, -8
    beq  t2, t3, test6
    j Fail_SLL_5

    # Test 6: slli basic
test6:
    li   t0, 5
    slli t2, t0, 3
    li   t3, 40
    beq  t2, t3, test7
    j Fail_SLL_6

    # Test 7: slli shift by 0
test7:
    li   t0, 123
    slli t2, t0, 0
    li   t3, 123
    beq  t2, t3, test8
    j Fail_SLL_7

    # Test 8: slli max shift (31)
test8:
    li   t0, 1
    slli t2, t0, 31
    li   t3, 0x80000000
    beq  t2, t3, test9
    j Fail_SLL_8

    # Test 9: Alternating bits
test9:
    li   t0, 0x55555555
    li   t1, 1
    sll  t2, t0, t1
    li   t3, 0xAAAAAAAA
    beq  t2, t3, test10
    j Fail_SLL_9

    # Test 10: Shift amount masking (e.g., 33 → 1 in RV32)
test10:
    li   t0, 7
    li   t1, 33        # 33 mod 32 = 1
    sll  t2, t0, t1
    li   t3, 14
    beq  t2, t3, pass
    j Fail_SLL_10


pass:
    j return_sll_test


Fail_SLL_1:
    li   gp, 401
    j    fail

Fail_SLL_2:
    li   gp, 402
    j    fail

Fail_SLL_3:
    li   gp, 403
    j    fail

Fail_SLL_4:
    li   gp, 404
    j    fail

Fail_SLL_5:
    li   gp, 405
    j    fail

Fail_SLL_6:
    li   gp, 406
    j    fail

Fail_SLL_7:
    li   gp, 407
    j    fail

Fail_SLL_8:
    li   gp, 408
    j    fail

Fail_SLL_9:
    li   gp, 409
    j    fail

Fail_SLL_10:
    li   gp, 410
    j    fail
