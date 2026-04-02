.extern return_blt_test
.extern fail

    .section .text.init
    .globl blt_test
    .type  blt_test, @function

blt_test:

test1:
    li   t0, 3
    li   t1, 5
    blt  t0, t1, test2
    j    Fail_BLT_1

test2:
    li   t0, 5
    li   t1, 3
    blt  t0, t1, Fail_BLT_2
    j    test3

test3:
    li   t0, -5
    li   t1, 2
    blt  t0, t1, test4
    j    Fail_BLT_3

test4:
    li   t0, -1
    li   t1, -8
    blt  t0, t1, Fail_BLT_4
    j    test5

test5:
    li   t0, -1
    li   t1, 1
    bltu t0, t1, Fail_BLT_5     # unsigned: 0xFFFFFFFF > 1
    j    test6

test6:
    li   t0, 0
    li   t1, -1
    bltu t0, t1, test7         # unsigned: 0 < 0xFFFFFFFF
    j    Fail_BLT_6

test7:
    li   t0, 7
    li   t1, 7
    blt  t0, t1, Fail_BLT_7
    j    test8

test8:
    li   t0, 0x7FFFFFFF
    li   t1, 0x80000000
    blt  t0, t1, Fail_BLT_8    # signed: positive > negative
    j    test9

test9:
    li   t0, 0x7FFFFFFF
    li   t1, 0x80000000
    bltu t0, t1, test10        # unsigned: smaller
    j    Fail_BLT_9

test10:
    li   t0, 0
loop10:
    addi t0, t0, 1
    li   t1, 4
    blt  t0, t1, loop10
    li   t2, 4
    beq  t0, t2, pass
    j    Fail_BLT_10


pass:
    j return_blt_test


Fail_BLT_1:
    li   gp, 461
    j    fail

Fail_BLT_2:
    li   gp, 462
    j    fail

Fail_BLT_3:
    li   gp, 463
    j    fail

Fail_BLT_4:
    li   gp, 464
    j    fail

Fail_BLT_5:
    li   gp, 465
    j    fail

Fail_BLT_6:
    li   gp, 466
    j    fail

Fail_BLT_7:
    li   gp, 467
    j    fail

Fail_BLT_8:
    li   gp, 468
    j    fail

Fail_BLT_9:
    li   gp, 469
    j    fail

Fail_BLT_10:
    li   gp, 470
    j    fail
