.extern return_bge_test
.extern fail

    .section .text.init
    .globl bge_test
    .type  bge_test, @function

bge_test:

test1:
    li   t0, 5
    li   t1, 3
    bge  t0, t1, test2
    j    Fail_BGE_1

test2:
    li   t0, 3
    li   t1, 5
    bge  t0, t1, Fail_BGE_2
    j    test3

test3:
    li   t0, -2
    li   t1, -5
    bge  t0, t1, test4
    j    Fail_BGE_3

test4:
    li   t0, -5
    li   t1, -2
    bge  t0, t1, Fail_BGE_4
    j    test5

test5:
    li   t0, 7
    li   t1, 7
    bge  t0, t1, test6
    j    Fail_BGE_5

test6:
    li   t0, -1
    li   t1, 1
    bgeu t0, t1, test7        # unsigned: 0xFFFFFFFF ≥ 1
    j    Fail_BGE_6

test7:
    li   t0, 1
    li   t1, -1
    bgeu t0, t1, Fail_BGE_7   # unsigned: 1 < 0xFFFFFFFF
    j    test8

test8:
    li   t0, 0
    li   t1, -1
    bgeu t0, t1, Fail_BGE_8   # unsigned: 0 < max
    j    test9

test9:
    li   t0, 0x80000000
    li   t1, 0x7FFFFFFF
    bge  t0, t1, Fail_BGE_9   # signed: negative < positive
    j    test10

test10:
    li   t0, 0
loop10:
    addi t0, t0, 1
    li   t1, 4
    bge  t0, t1, exit10
    j    loop10

exit10:
    li   t2, 4
    beq  t0, t2, pass
    j    Fail_BGE_10


pass:
    j return_bge_test


Fail_BGE_1:
    li   gp, 471
    j    fail

Fail_BGE_2:
    li   gp, 472
    j    fail

Fail_BGE_3:
    li   gp, 473
    j    fail

Fail_BGE_4:
    li   gp, 474
    j    fail

Fail_BGE_5:
    li   gp, 475
    j    fail

Fail_BGE_6:
    li   gp, 476
    j    fail

Fail_BGE_7:
    li   gp, 477
    j    fail

Fail_BGE_8:
    li   gp, 478
    j    fail

Fail_BGE_9:
    li   gp, 479
    j    fail

Fail_BGE_10:
    li   gp, 480
    j    fail
