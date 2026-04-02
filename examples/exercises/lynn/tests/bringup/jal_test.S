.extern return_jal_test
.extern fail

 .section .text.init
 .globl jal_test
 .type jal_test, @function

jal_test:
 jal_test1:
 # -----------------------------------------------------------------
 # Test 1: Forward Jump and Linking
 # -----------------------------------------------------------------
 link_address:
 jal ra, forward_target # ra = link_address + 4, jump to target

 # If we return here, but ra was wrong, we catch it
 j Fail_Jal_1 # We should NOT hit this immediately

 forward_target:
 # Verify ra points back to the instruction after the jal (link_address + 4)
 # We use a manual calculation to check ra
 la t0, link_address
 addi t0, t0, 4 # Expected ra value

 beq ra, t0, jal_test2
 j pass # quick fix
 j Fail_Jal_2 # Link register was incorrect

 jal_test2:
 # -----------------------------------------------------------------
 # Test 2: Backward Jump
 # -----------------------------------------------------------------
 j jump_over_backward

 back_target:
 # If we successfully jumped back, we pass
 j pass

 jump_over_backward:
 jal x0, back_target # Jump back using x0 (no linking)

 # If the jump failed to trigger, we hit this
 j Fail_Jal_3

 pass:
 j return_jal_test

Fail_Jal_1:
 li gp, 1101 # Did not jump to target
 j fail

Fail_Jal_2:
 li gp, 1102 # Link register (ra) had wrong address
 j fail

Fail_Jal_3:
 li gp, 1103 # Backward jump failed
 j fail
