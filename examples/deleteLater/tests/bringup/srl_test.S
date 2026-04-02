.extern return_srl_test
.extern fail

    .section .text.init
    .globl srl_test
    .type  srl_test, @function

srl_test:

    # Test 1: Basic srl
test1:
    li   t0, 16
    li   t1, 2
    srl  t2, t0, t1
    li   t3, 4
    beq  t2, t3, test2
    j Fail_SRL_1

    # Test 2: Shift by 0
test2:
    li   t0, 123
    li   t1, 0
    srl  t2, t0, t1
    li   t3, 123
    beq  t2, t3, test3
    j Fail_SRL_2

    # Test 3: Shift by 31 (MSB to LSB)
test3:
    li   t0, 0x80000000
    li   t1, 31
    srl  t2, t0, t1
    li   t3, 1
    beq  t2, t3, test4
    j Fail_SRL_3

    # Test 4: Logical shift of negative number
test4:
    li   t0, -4              # 0xFFFFFFFC
    li   t1, 1
    srl  t2, t0, t1
    li   t3, 0x7FFFFFFE
    beq  t2, t3, test5
    j Fail_SRL_4

    # Test 5: Clear LSBs
test5:
    li   t0, 7
    li   t1, 1
    srl  t2, t0, t1
    li   t3, 3
    beq  t2, t3, test6
    j Fail_SRL_5

    # Test 6: srli basic
test6:
    li   t0, 64
    srli t2, t0, 3
    li   t3, 8
    beq  t2, t3, test7
    j Fail_SRL_6

    # Test 7: srli shift by 0
test7:
    li   t0, 999
    srli t2, t0, 0
    li   t3, 999
    beq  t2, t3, test8
    j Fail_SRL_7

    # Test 8: srli max shift (31)
test8:
    li   t0, 0x80000000
    srli t2, t0, 31
    li   t3, 1
    beq  t2, t3, test9
    j Fail_SRL_8

    # Test 9: Alternating bits
test9:
    li   t0, 0xAAAAAAAA
    li   t1, 1
    srl  t2, t0, t1
    li   t3, 0x55555555
    beq  t2, t3, test10
    j Fail_SRL_9

    # Test 10: Shift amount masking (33 → 1 in RV32)
test10:
    li   t0, 14
    li   t1, 33        # 33 mod 32 = 1
    srl  t2, t0, t1
    li   t3, 7
    beq  t2, t3, pass
    j Fail_SRL_10


pass:
    j return_srl_test


Fail_SRL_1:
    li   gp, 411
    j    fail

Fail_SRL_2:
    li   gp, 412
    j    fail

Fail_SRL_3:
    li   gp, 413
    j    fail

Fail_SRL_4:
    li   gp, 414
    j    fail

Fail_SRL_5:
    li   gp, 415
    j    fail

Fail_SRL_6:
    li   gp, 416
    j    fail

Fail_SRL_7:
    li   gp, 417
    j    fail

Fail_SRL_8:
    li   gp, 418
    j    fail

Fail_SRL_9:
    li   gp, 419
    j    fail

Fail_SRL_10:
    li   gp, 420
    j    fail
