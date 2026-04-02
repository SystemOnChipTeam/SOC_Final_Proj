// Tests for AUIPC (Add Upper Immediate to PC)
// Logic: rd = PC + {imm[31:12], 12'b0}
// Constraints: Only addi, beq, j, lui, and auipc.

.extern return_auipc_test
.extern fail
.section .text.init
.globl auipc_test
.type auipc_test, @function

auipc_test:

    # -----------------------------------------------------------------
    # Test 1: Basic PC Addition
    # Logic: auipc t1, 0 -> t1 should equal the current PC.
    # -----------------------------------------------------------------
test1:
    # We can capture the current PC by using auipc with a 0 immediate.
capture_pc:
    auipc   t1, 0               # t1 = PC_of_this_instruction

    # To verify, we calculate what the PC was at 'capture_pc'
    # using the 'la' (load address) pseudo-instruction or labels.
    # Since we can't use 'la', we use the relative distance from the start.
    lui     t2, %hi(capture_pc)
    addi    t2, t2, %lo(capture_pc)

    beq     t1, t2, test2
    j       Fail_Auipc_1

    # -----------------------------------------------------------------
    # Test 2: Adding a Large Offset
    # Logic: auipc t1, 1 -> t1 should be (PC + 0x1000)
    # -----------------------------------------------------------------
test2:
    # This instruction is at some address 'PC_A'
pc_a:
    auipc   t1, 1               # t1 = PC_A + 0x1000

    # Construct expectation: (Address of pc_a) + 4096
    lui     t2, %hi(pc_a)
    addi    t2, t2, %lo(pc_a)
    li      t3, 4096
    add     t2, t2, t3          # t2 = PC_A + 4096

    beq     t1, t2, test3
    j       Fail_Auipc_2

    # -----------------------------------------------------------------
    # Test 3: Negative Offset (Sign bit check)
    # Logic: auipc t1, 0xFFFFF -> t1 should be (PC - 0x1000)
    # -----------------------------------------------------------------
test3:
pc_b:
    auipc   t1, 0xFFFFF         # 0xFFFFF is -1 in 20-bit signed world
                                # t1 = PC_B - 0x1000 (4096)

    lui     t2, %hi(pc_b)
    addi    t2, t2, %lo(pc_b)
    li      t3, -4096
    add     t2, t2, t3

    beq     t1, t2, pass
    j       Fail_Auipc_3

pass:
    j return_auipc_test

# --- Failure Handlers ---
Fail_Auipc_1:
    li gp, 1301
    j fail
Fail_Auipc_2:
    li gp, 1302
    j fail
Fail_Auipc_3:
    li gp, 1303
    j fail
