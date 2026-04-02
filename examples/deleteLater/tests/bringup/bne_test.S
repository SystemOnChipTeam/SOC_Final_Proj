.extern return_bne_test
.extern fail

    .section .text.init
    .globl bne_test
    .type  bne_test, @function

bne_test:

############################################################
# Test 1: Branch taken (simple)
############################################################
test1:
    li   t0, 5
    li   t1, 6
    bne  t0, t1, test2
    j    Fail_BNE_1

############################################################
# Test 2: Branch NOT taken
############################################################
test2:
    li   t0, 7
    li   t1, 7
    bne  t0, t1, Fail_BNE_2
    j    test3

############################################################
# Test 3: Zero vs nonzero
############################################################
test3:
    li   t0, 0
    li   t1, 1
    bne  t0, t1, test4
    j    Fail_BNE_3

############################################################
# Test 4: Negative values unequal
############################################################
test4:
    li   t0, -1
    li   t1, -2
    bne  t0, t1, test5
    j    Fail_BNE_4

############################################################
# Test 5: Negative values equal
############################################################
test5:
    li   t0, -8
    li   t1, -8
    bne  t0, t1, Fail_BNE_5
    j    test6

############################################################
# Test 6: Large unequal values
############################################################
test6:
    li   t0, 0x7FFFFFFF
    li   t1, 0x80000000
    bne  t0, t1, test7
    j    Fail_BNE_6

############################################################
# Test 7: Back-to-back branches
############################################################
test7:
    li   t0, 3
    li   t1, 4
    bne  t0, t1, branch7_taken
    j    Fail_BNE_7

branch7_taken:
    bne  t0, t1, test8
    j    Fail_BNE_7

############################################################
# Test 8: Forward skip over instruction
############################################################
test8:
    li   t0, 1
    li   t1, 2
    bne  t0, t1, skip8
    j    Fail_BNE_8

skip8:
    j    test9

############################################################
# Test 9: Backward branch
############################################################
test9:
    li   t0, 0
loop9:
    addi t0, t0, 1
    li   t1, 3
    bne  t0, t1, loop9
    j    test10

############################################################
# Test 10: Ensure fallthrough works
############################################################
test10:
    li   t0, 100
    li   t1, 100
    bne  t0, t1, Fail_BNE_10
    j    pass


############################################################
# PASS
############################################################
pass:
    j return_bne_test


############################################################
# FAIL HANDLERS
############################################################

Fail_BNE_1:
    li   gp, 451
    j    fail

Fail_BNE_2:
    li   gp, 452
    j    fail

Fail_BNE_3:
    li   gp, 453
    j    fail

Fail_BNE_4:
    li   gp, 454
    j    fail

Fail_BNE_5:
    li   gp, 455
    j    fail

Fail_BNE_6:
    li   gp, 456
    j    fail

Fail_BNE_7:
    li   gp, 457
    j    fail

Fail_BNE_8:
    li   gp, 458
    j    fail

Fail_BNE_9:
    li   gp, 459
    j    fail

Fail_BNE_10:
    li   gp, 460
    j    fail
