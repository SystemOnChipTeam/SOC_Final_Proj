.extern return_lui_test
.extern fail

    .section .text.init
    .globl lui_test
    .type  lui_test, @function

lui_test:

test1:
    lui  t0, 0x1
    li   t1, 0x00001000
    beq  t0, t1, test2
    j    Fail_LUI_1

test2:
    lui  t0, 0xABCDE
    li   t1, 0xABCDE000
    beq  t0, t1, test3
    j    Fail_LUI_2

test3:
    lui  t0, 0x0
    li   t1, 0x00000000
    beq  t0, t1, test4
    j    Fail_LUI_3

test4:
    lui  t0, 0xFFFFF
    lui  t1, 0xFFFFF
    beq  t0, t1, test5
    j    Fail_LUI_4

test5:
    lui  t0, 0x80000
    lui  t1, 0x80000
    beq  t0, t1, test6

test6:
    li   t0, 123
    lui  t0, 0x12345       # overwrite previous value
    li   t1, 0x12345000
    beq  t0, t1, test7
    j    Fail_LUI_6

test7:
    lui  t2, 0x7FFFF
    li   t3, 0x7FFFF000
    beq  t2, t3, test8
    j    Fail_LUI_7

test8:
    lui  t4, 0x13579
    li   t5, 0x13579000
    beq  t4, t5, test9
    j    Fail_LUI_8

test9:
    lui t6, 0x2468A
    lui t5, 0x2468A
    beq t6, t5, test10
    j    Fail_LUI_9

test10:
    lui  s0, 0x40000
    li   s1, 0x40000000
    beq  s0, s1, pass
    j    Fail_LUI_10


pass:
    j return_lui_test


Fail_LUI_1:
    li   gp, 491
    j    fail

Fail_LUI_2:
    li   gp, 492
    j    fail

Fail_LUI_3:
    li   gp, 493
    j    fail

Fail_LUI_4:
    li   gp, 494
    j    fail

Fail_LUI_5:
    li   gp, 495
    j    fail

Fail_LUI_6:
    li   gp, 496
    j    fail

Fail_LUI_7:
    li   gp, 497
    j    fail

Fail_LUI_8:
    li   gp, 498
    j    fail

Fail_LUI_9:
    li   gp, 499
    j    fail

Fail_LUI_10:
    li   gp, 500
    j    fail
