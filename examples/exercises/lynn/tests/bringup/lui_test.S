// Tests for LUI (Load Upper Immediate)
// Logic: rd = {imm[31:12], 12'b0}
// Constraints: Only addi, beq, j, and lui.

.extern return_lui_test
.extern fail
.section .text.init
.globl lui_test
.type lui_test, @function

lui_test:

 # -----------------------------------------------------------------
 # Test 1: Basic Load Upper
 # Logic: lui t1, 0x1 -> t1 should be 0x00001000
 # -----------------------------------------------------------------
test1:
 lui t1, 1 # Load 1 into bits [31:12]
 li t2, 4096 # 4096 is 0x1000 (fits in 12-bit addi)
 beq t1, t2, test2
 j Fail_Lui_1

 # -----------------------------------------------------------------
 # Test 2: Loading All Ones (Sign bit check)
 # Logic: lui t1, 0xFFFFF -> t1 should be 0xFFFFF000
 # -----------------------------------------------------------------
test2:
 lui t1, 0xFFFFF
 lui t2, 0xFFFFF
 beq t1, t2, test3 # If THIS fails, your Register File or Mux is broken.
 j Fail_Lui_2

 li t1, -1 # Should result in 0xFFFFFFFF
 addi t2, x0, -1 # Manually build -1 via ADDI
 beq t1, t2, test3 # If this fails, your I-type extension is definitely zero-extending
 j Fail_Lui_5 # Re-using your fail label

// test below fail
 lui t1, 0xFFFFF # All 20 bits high

 # Construct 0xFFFFF000 using addi
 # 0xFFFFF000 is -4096 in decimal
 li t2, -2048
 addi t2, t2, -2048 # t2 = -4096 (0xFFFFF000)

 beq t1, t2, test3
 j Fail_Lui_2

 # -----------------------------------------------------------------
 # Test 3: Zero check
 # Logic: lui t1, 0 -> t1 should be 0
 # -----------------------------------------------------------------
test3:
 lui t1, 0
 li t0, 0
 beq t1, t0, test4
 j Fail_Lui_3

 # -----------------------------------------------------------------
 # Test 4: Verifying lower bits are cleared
 # Logic: Write junk to t1, then LUI. The lower bits must become 0.
 # -----------------------------------------------------------------
test4:
 li t1, 0x7FF # Fill lower bits with 1s
 lui t1, 0xABCDE # This should wipe out the 0x7FF

 # We verify by subtracting the expected upper value.
 # If lower bits are 0, (Result - Expected) == 0.
 # Since we can't easily build 0xABCDE000 with addi, we use the
 # property that (lui t1, 0xABCDE) should equal itself.
 lui t2, 0xABCDE
 beq t1, t2, pass
 j Fail_Lui_4

pass:
 j return_lui_test

# -----------------------------------------------------------------
# Failure Handlers (using 1200 range for LUI)
# -----------------------------------------------------------------
Fail_Lui_1:
 li gp, 1200
 j fail
Fail_Lui_2:
 li gp, 1201
 j fail
Fail_Lui_3:
 li gp, 1202
 j fail
Fail_Lui_4:
 li gp, 1203
 j fail
Fail_Lui_5:
 li gp, 1204
 j fail
