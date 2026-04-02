// sw_test.S
// Constraints: NO lui, auipc, jalr, bne, shifts.
// Strategy: Use JAL to get PC, then offset to find valid RAM.

.extern return_sw_test
.extern fail
.section .text.init
.globl sw_test
.type sw_test, @function

sw_test:
 # -----------------------------------------------------------------
 # 1. Setup Pointer (The "No LUI" Workaround)
 # -----------------------------------------------------------------
 # We can't load 0x80000000 directly.
 # But we ARE executing at 0x8000xxxx.
 # We use JAL to put the current PC into t0.

 jal t0, get_pc_label # t0 = PC of 'get_pc_label'

get_pc_label:
 # t0 now holds a valid memory address (e.g., 0x80000004).
 # We need to write to memory, but NOT over our own code.
 # We add 256 bytes (0x100) to t0. This points to empty RAM ahead.

 addi t0, t0, 256 # t0 = t0 + 256

 # -----------------------------------------------------------------
 # 2. Setup Data
 # -----------------------------------------------------------------
 # We can't use large numbers because LUI is banned.
 # We use a small immediate.
 addi t1, zero, 42 # t1 = 42 (0x2A)

 # -----------------------------------------------------------------
 # 3. The Test
 # -----------------------------------------------------------------
 sw t1, 0(t0) # Store 42 to [PC + 256]
 lw t2, 0(t0) # Load it back

 # -----------------------------------------------------------------
 # 4. Verification (The "No BNE" Workaround)
 # -----------------------------------------------------------------
 # We want: if (t1 != t2) goto fail.
 # But BNE is banned.
 # So we use: if (t1 == t2) goto pass;

 beq t1, t2, test_passed

 # If we are here, they were NOT equal. Fall through to fail.
 li gp, 701
 jal zero, fail

test_passed:
 # Return to main test loop
 # Note: We use JAL because JALR (ret) is banned.
 jal zero, return_sw_test
