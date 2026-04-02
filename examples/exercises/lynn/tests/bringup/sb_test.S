// Tests for SB (Store Byte)
// Constraints: Only li, lw, sw, sb, beq, j, lui, addi.

.extern return_sb_test
.extern fail
.section .text.init
.globl sb_test
.type sb_test, @function

sb_test:
    # Set base address to 0x80000100
    lui     s0, 0x80000         # s0 = 0x80000000
    addi    s0, s0, 0x100       # s0 = 0x80000100 (Safe offset)

    # -----------------------------------------------------------------
    # Test 1: Build a word byte-by-byte
    # Logic: Store 4 bytes sequentially, then read as 1 word.
    # Expected word value: 0x44332211
    # -----------------------------------------------------------------
test_sb_1:
    li      t1, 0x11
    sb      t1, 0(s0)           # Write 0x11 to byte 0
    li      t1, 0x22
    sb      t1, 1(s0)           # Write 0x22 to byte 1
    li      t1, 0x33
    sb      t1, 2(s0)           # Write 0x33 to byte 2
    li      t1, 0x44
    sb      t1, 3(s0)           # Write 0x44 to byte 3

    lw      t2, 0(s0)           # Read back the full word
    li      t3, 0x44332211      # Little-endian expectation
    beq     t2, t3, test_sb_2
    j       Fail_Sb_1

    # -----------------------------------------------------------------
    # Test 2: Overwrite a single middle byte
    # Logic: Change byte 2 from 0x33 to 0xFF.
    # -----------------------------------------------------------------
test_sb_2:
    li      t1, 0xFF
    sb      t1, 2(s0)           # Overwrite byte 2 only

    lw      t2, 0(s0)           # Should now be 0x44FF2211
    lui     t3, 0x44FF2
    addi    t3, t3, 0x211
    beq     t2, t3, test_sb_3
    j       Fail_Sb_2

    # -----------------------------------------------------------------
    # Test 3: Truncation Check
    # Logic: Provide a 32-bit value to SB. It must ONLY store the bottom 8 bits.
    # -----------------------------------------------------------------
test_sb_3:
    li      t1, 0x999999AA
    sb      t1, 0(s0)           # Should only write 0xAA to byte 0

    lw      t2, 0(s0)           # Should now be 0x44FF22AA
    lui     t3, 0x44FF2
    addi    t3, t3, 0x2AA
    beq     t2, t3, pass_sb
    j       Fail_Sb_3

pass_sb:
    j return_sb_test

# --- Failure Handlers ---
Fail_Sb_1:
    li gp, 1601
    j fail
Fail_Sb_2:
    li gp, 1602
    j fail
Fail_Sb_3:
    li gp, 1603
    j fail
