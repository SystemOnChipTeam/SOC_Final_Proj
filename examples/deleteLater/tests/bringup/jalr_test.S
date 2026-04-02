.extern return_jalr_test
.extern fail

.section .text.init
.globl jalr_test
.type  jalr_test, @function

jalr_test:

############################################################
# TEST 1 — basic jalr, link into ra
############################################################
test1:
    la    t0, target1
    jalr  ra, 0(t0)
ret1:                          # this MUST equal PC+4
    j     Fail_JALR_1          # should never execute

target1:
    la    t1, ret1
    bne   ra, t1, Fail_JALR_1
    j     test2


############################################################
# TEST 2 — odd address masking
############################################################
test2:
    la    t0, target2
    addi  t0, t0, 1            # force odd address
    jalr  ra, 0(t0)
ret2:
    j     Fail_JALR_2

target2:
    la    t1, ret2
    bne   ra, t1, Fail_JALR_2
    j     test3


############################################################
# TEST 3 — link into non-ra register
############################################################
test3:
    la    t0, target3
    jalr  t2, 0(t0)
ret3:
    j     Fail_JALR_3

target3:
    la    t3, ret3
    bne   t2, t3, Fail_JALR_3
    j     test4


############################################################
# TEST 4 — rd = x0 (no link written)
############################################################
test4:
    li    ra, 0x12345678
    la    t0, target4
    jalr  x0, 0(t0)
    j     Fail_JALR_4

target4:
    li    t1, 0x12345678
    bne   ra, t1, Fail_JALR_4
    j     test5


############################################################
# TEST 5 — return using jalr x0, 0(ra)  (RV32I compliant)
############################################################
test5:
    la    t0, target5
    jalr  ra, 0(t0)
ret5:
    j     test6

target5:
    li    t1, -2            # t1 = 0xFFFFFFFE
    and   ra, ra, t1        # clear LSB (RV32I legal)
    jalr  x0, 0(ra)         # return
    j     Fail_JALR_5


############################################################
# TEST 6 — offset behavior
############################################################
test6:
    la    t0, target6
    jalr  ra, 4(t0)            # jump to after6
ret6:
    j     Fail_JALR_6

target6:
    nop
after6:
    la    t1, ret6
    bne   ra, t1, Fail_JALR_6
    j     test7


############################################################
# TEST 7 — control flow integrity
############################################################
test7:
    la    t0, loop7
    jalr  ra, 0(t0)
ret7:
    j     Fail_JALR_7

loop7:
    li    t1, 1
    beq   t1, t1, test8


############################################################
# TEST 8 — forward jump
############################################################
test8:
    la    t0, target8
    jalr  ra, 0(t0)
ret8:
    j     Fail_JALR_8

target8:
    la    t1, ret8
    bne   ra, t1, Fail_JALR_8
    j     test9


############################################################
# TEST 9 — jump into block with instructions
############################################################
test9:
    la    t0, target9
    jalr  ra, 0(t0)
ret9:
    j     Fail_JALR_9

target9:
    li    t2, 123
    beq   t2, t2, test10


############################################################
# TEST 10 — final verification
############################################################
test10:
    la    t0, target10
    jalr  ra, 0(t0)
ret10:
    j     Fail_JALR_10

target10:
    la    t1, ret10
    bne   ra, t1, Fail_JALR_10
    j     pass


############################################################
# PASS
############################################################
pass:
    j return_jalr_test


############################################################
# FAIL HANDLERS
############################################################
Fail_JALR_1:  li gp, 481 ; j fail
Fail_JALR_2:  li gp, 482 ; j fail
Fail_JALR_3:  li gp, 483 ; j fail
Fail_JALR_4:  li gp, 484 ; j fail
Fail_JALR_5:  li gp, 485 ; j fail
Fail_JALR_6:  li gp, 486 ; j fail
Fail_JALR_7:  li gp, 487 ; j fail
Fail_JALR_8:  li gp, 488 ; j fail
Fail_JALR_9:  li gp, 489 ; j fail
Fail_JALR_10: li gp, 490 ; j fail
