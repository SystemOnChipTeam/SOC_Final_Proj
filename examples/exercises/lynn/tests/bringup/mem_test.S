.extern return_mem_test
.extern fail

    .section .data
    .globl mem_test
    .align 2

# Known initialized memory values
test_bytes:
    .byte 0x7F        # +127
    .byte 0x80        # -128 signed
    .byte 0xFF        # -1 signed
    .byte 0x01

test_halfwords:
    .half 0x7FFF      # +32767
    .half 0x8000      # -32768 signed
    .half 0xFFFF      # -1 signed
    .half 0x0001

store_area:
    .space 8          # Safe writable area

    .section .text.init
    .globl lb_test
    .type  lb_test, @function

mem_test:

############################################################
# LOAD TESTS
############################################################

# Test 1: lb positive value
test1:
    lui  t0, %hi(test_bytes)
    addi t0, t0, %lo(test_bytes)
    lb   t2, 0(t0)
    li   t3, 127
    beq  t2, t3, test2
    j    Fail_MEM_1

# Test 2: lb negative value (sign extend)
test2:
    lui  t0, %hi(test_bytes)
    addi t0, t0, %lo(test_bytes)
    lb   t2, 1(t0)
    li   t3, -128
    beq  t2, t3, test3
    j    Fail_MEM_2

# Test 3: lbu zero extend
test3:
    lui  t0, %hi(test_bytes)
    addi t0, t0, %lo(test_bytes)
    lbu  t2, 1(t0)
    li   t3, 128
    beq  t2, t3, test4
    j    Fail_MEM_3

# Test 4: lb -1
test4:
    lui  t0, %hi(test_bytes)
    addi t0, t0, %lo(test_bytes)
    lb   t2, 2(t0)
    li   t3, -1
    beq  t2, t3, test5
    j    Fail_MEM_4

# Test 5: lbu -1 (should be 255)
test5:
    lui  t0, %hi(test_bytes)
    addi t0, t0, %lo(test_bytes)
    lbu  t2, 2(t0)
    li   t3, 255
    beq  t2, t3, test6
    j    Fail_MEM_5

# Test 6: lh positive
test6:
    lui  t0, %hi(test_halfwords)
    addi t0, t0, %lo(test_halfwords)
    lh   t2, 0(t0)
    li   t3, 32767
    beq  t2, t3, test7
    j    Fail_MEM_6

# Test 7: lh negative (sign extend)
test7:
    lui  t0, %hi(test_halfwords)
    addi t0, t0, %lo(test_halfwords)
    lh   t2, 2(t0)
    li   t3, -32768
    beq  t2, t3, test8
    j    Fail_MEM_7

# Test 8: lhu zero extend
test8:
    lui  t0, %hi(test_halfwords)
    addi t0, t0, %lo(test_halfwords)
    lhu  t2, 2(t0)
    li   t3, 32768
    beq  t2, t3, test9
    j    Fail_MEM_8

############################################################
# STORE TESTS
############################################################

# Test 9: sb then lb
test9:
    lui  t0, %hi(store_area)
    addi t0, t0, %lo(store_area)
    li   t1, -5
    sb   t1, 0(t0)
    lb   t2, 0(t0)
    li   t3, -5
    beq  t2, t3, test10
    j    Fail_MEM_9

# Test 10: sh then lh
test10:
    lui  t0, %hi(store_area)
    addi t0, t0, %lo(store_area)
    li   t1, -1234
    sh   t1, 2(t0)
    lh   t2, 2(t0)
    li   t3, -1234
    beq  t2, t3, pass
    j    Fail_MEM_10

pass:
    j return_mem_test


############################################################
# FAIL HANDLERS
############################################################

Fail_MEM_1:
    li   gp, 441
    j    fail

Fail_MEM_2:
    li   gp, 442
    j    fail

Fail_MEM_3:
    li   gp, 443
    j    fail

Fail_MEM_4:
    li   gp, 444
    j    fail

Fail_MEM_5:
    li   gp, 445
    j    fail

Fail_MEM_6:
    li   gp, 446
    j    fail

Fail_MEM_7:
    li   gp, 447
    j    fail

Fail_MEM_8:
    li   gp, 448
    j    fail

Fail_MEM_9:
    li   gp, 449
    j    fail

Fail_MEM_10:
    li   gp, 450
    j    fail
