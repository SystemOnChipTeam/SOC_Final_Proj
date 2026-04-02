.extern return_auipc_test
.extern fail

    .section .text.init
    .globl auipc_test
    .type  auipc_test, @function

auipc_test:

test1:
    auipc t0, 0
    la    t1, test1
    beq   t0, t1, test2
    j     Fail_AUIPC_1

test2:
    auipc t0, 1              # PC + 0x1000
    la    t1, test2
    lui   t2, 1              # t2 = 0x1000
    add   t1, t1, t2
    beq   t0, t1, test4
    j     Fail_AUIPC_2

test4:
    auipc t2, 0x7FFFF
    la    t3, test4
    lui   t4, 0x7FFFF
    add   t3, t3, t4
    beq   t2, t3, test5
    j     Fail_AUIPC_4

test5:
    auipc t0, 0
    auipc t1, 0
    addi  t0, t0, 4          # legal small immediate
    beq   t0, t1, test6
    j     Fail_AUIPC_5

test6:
    auipc t0, 2              # +0x2000
    la    t1, test6
    lui   t2, 2
    add   t1, t1, t2
    beq   t0, t1, test7
    j     Fail_AUIPC_6

test7:
    auipc t1, 0          # t1 = PC_before (call this P)
    auipc t0, 3          # t0 = (P+4) + 0x3000

    # Build 0x3000 using shifts (no addi)
    li    t2, 3
    slli  t2, t2, 12     # t2 = 0x3000

    add   t3, t1, t2     # t3 = P + 0x3000
    add   t3, t3, 4      # compensate for PC difference

    beq   t0, t3, test9
    j     Fail_AUIPC_7

test9:
    auipc s0, 1
    la    s1, test9
    lui   s2, 1
    add   s1, s1, s2
    beq   s0, s1, test10
    j     Fail_AUIPC_9

test10:
    auipc t0, 0
    la    t1, test10
    beq   t0, t1, pass
    j     Fail_AUIPC_10


pass:
    j return_auipc_test


Fail_AUIPC_1:
    li   gp, 501
    j    fail
Fail_AUIPC_2:
    li   gp, 502
    j    fail
Fail_AUIPC_3:
    li   gp, 503
    j    fail
Fail_AUIPC_4:
    li   gp, 504
    j    fail
Fail_AUIPC_5:
    li   gp, 505
    j    fail
Fail_AUIPC_6:
    li   gp, 506
    j    fail
Fail_AUIPC_7:
    li   gp, 507
    j    fail
Fail_AUIPC_8:
    li   gp, 508
    j    fail
Fail_AUIPC_9:
    li   gp, 509
    j    fail
Fail_AUIPC_10:
    li   gp, 510
    j    fail
