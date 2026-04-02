// Tests for SH (Store Halfword)
// Constraints: Only li, lw, sw, sh, beq, j, lui, addi.

.extern return_sh_test
.extern fail
.section .text.init
.globl sh_test
.type sh_test, @function

sh_test:
    # Set base address to 0x80000108
    lui     s0, 0x80000
    addi    s0, s0, 0x108

    # -----------------------------------------------------------------
    # Test 1: Build a word halfword-by-halfword
    # Logic: Store 2 halfwords sequentially, then read as 1 word.
    # Expected word value: 0x44332211
    # -----------------------------------------------------------------
test_sh_1:
    li      t1, 0x2211
    sh      t1, 0(s0)           # Write 0x2211 to lower half (bytes 1:0)
    li      t1, 0x4433
    sh      t1, 2(s0)           # Write 0x4433 to upper half (bytes 3:2)

    lw      t2, 0(s0)           # Read back the full word
    li      t3, 0x44332211      # Little-endian expectation
    beq     t2, t3, test_sh_2
    j       Fail_Sh_1

    # -----------------------------------------------------------------
    # Test 2: Overwrite upper halfword
    # Logic: Change upper half from 0x4433 to 0xFFFF.
    # Validates WriteByteEn mask (4'b1100) doesn't kill the lower half.
    # -----------------------------------------------------------------
test_sh_2:
    li      t1, 0xFFFF
    sh      t1, 2(s0)           # Overwrite bytes 3:2 only

    lw      t2, 0(s0)           # Should now be 0xFFFF2211
    lui     t3, 0xFFFF2
    addi    t3, t3, 0x211
    beq     t2, t3, test_sh_3
    j       Fail_Sh_2

    # -----------------------------------------------------------------
    # Test 3: Truncation Check
    # Logic: Provide a 32-bit value to SH. It must ONLY store the bottom 16 bits.
    # -----------------------------------------------------------------
test_sh_3:
    li      t1, 0x9999AAAA
    sh      t1, 0(s0)           # Should only write 0xAAAA to the lower half

    lw      t2, 0(s0)           # Should now be 0xFFFFAAAA
    lui     t3, 0xFFFFB         # 0xFFFFB000 (Adjusting for sign-extension of 0xAAAA)
    addi    t3, t3, -1366       # -1366 is 0xAAAA. 0xFFFFB000 - 1366 = 0xFFFFAAAA
    beq     t2, t3, pass_sh
    j       Fail_Sh_3

pass_sh:
    j return_sh_test

# --- Failure Handlers ---
Fail_Sh_1:
    li gp, 1801
    j fail
Fail_Sh_2:
    li gp, 1802
    j fail
Fail_Sh_3:
    li gp, 1803
    j fail
