// Pierce Clark
// pclark@hmc.edu
// 2/9/2026

.extern return_lab_test
.extern fail

    .section .text.init
    .globl lab_test
    .type  lab_test, @function

lab_test:

sll_test:
    sll_test1:
        li   t0, 3
        li   t1, 3
        sll t2, t0, t1
        li   t3, 12
        beq  t2, t3, sll_test2
        j    Fail_sll_1

    sll_test2:
        li   t0, 2
        li   t1, 4
        sll t2, t0, t1
        li   t3, 32
        beq  t2, t3, slli_test
        j    Fail_sll_2

    Fail_sll_1:
        li   gp, 501
        j    fail

    Fail_sll_2:
        li   gp, 502
        j    fail

slli_test:
    slli_test1:
            li   t0, 5
            slli t2, t0, 1
            li   t3, 10
            beq  t2, t3, slli_test2
            j    Fail_slli_1

    slli_test2:
            li   t0, 6
            slli t2, t0, 3
            li   t3, 48
            beq  t2, t3, srl_test
            j    Fail_slli_2

    Fail_slli_1:
        li   gp, 601
        j    fail

    Fail_slli_2:
        li   gp, 602
        j    fail

srl_test:
    srl_test1:
            li   t0, 16
            li   t1, 2
            srl  t2, t0, t1
            li   t3, 4
            beq  t2, t3, srl_test2
            j    Fail_srl_1

    srl_test2:
            li   t0, 30
            li   t1, 1
            srl  t2, t0, t1
            li   t3, 15
            beq  t2, t3, srli_test
            j    Fail_srl_2

    Fail_srl_1:
        li   gp, 701
        j    fail

    Fail_srl_2:
        li   gp, 702
        j    fail

srli_test:
    srli_test1:
            li   t0, 32
            srli t2, t0, 3
            li   t3, 4
            beq  t2, t3, srli_test2
            j    Fail_srli_1

    srli_test2:
            li   t0, 40
            srli t2, t0, 2
            li   t3, 10
            beq  t2, t3, sra_test
            j    Fail_srli_2

    Fail_srli_1:
        li   gp, 801
        j    fail

    Fail_srli_2:
        li   gp, 802
        j    fail

sra_test:
    sra_test1:
            li   t0, -16
            li   t1, 2
            sra  t2, t0, t1
            li   t3, -4
            beq  t2, t3, sra_test2
            j    Fail_sra_1

    sra_test2:
            li   t0, 32
            li   t1, 3
            sra  t2, t0, t1
            li   t3, 4
            beq  t2, t3, srai_test
            j    Fail_sra_2

    Fail_sra_1:
        li   gp, 901
        j    fail

    Fail_sra_2:
        li   gp, 902
        j    fail

srai_test:
    srai_test1:
            li   t0, -32
            srai t2, t0, 3
            li   t3, -4
            beq  t2, t3, srai_test2
            j    Fail_srai_1

    srai_test2:
            li   t0, 64
            srai t2, t0, 4
            li   t3, 4
            beq  t2, t3, sltu_test
            j    Fail_srai_2

    Fail_srai_1:
        li   gp, 1001
        j    fail

    Fail_srai_2:
        li   gp, 1002
        j    fail

sltu_test:
    sltu_test1:
            li   t0, -1
            li   t1, 1
            sltu t2, t0, t1
            li   t3, 0
            beq  t2, t3, sltu_test2
            j    Fail_sltu_1

    sltu_test2:
            li   t0, 1
            li   t1, -1
            sltu t2, t0, t1
            li   t3, 1
            beq  t2, t3, sltiu_test
            j    Fail_sltu_2

    Fail_sltu_1:
        li   gp, 1101
        j    fail

    Fail_sltu_2:
        li   gp, 1102
        j    fail

sltiu_test:
    sltiu_test1:
            li   t0, 5
            sltiu t2, t0, 10
            li   t3, 1
            beq  t2, t3, sltiu_test2
            j    Fail_sltiu_1

    sltiu_test2:
            li   t0, -1
            sltiu t2, t0, 1
            li   t3, 0
            beq  t2, t3, lb_test
            j    Fail_sltiu_2

    Fail_sltiu_1:
        li   gp, 1201
        j    fail

    Fail_sltiu_2:
        li   gp, 1202
        j    fail

lb_test:
    lb_test1:
            la   t0, mem_lb       # base address
            li   t1, 0x7F
            sb   t1, 0(t0)
            lb   t2, 0(t0)
            li   t3, 0x7F
            beq  t2, t3, lb_test2
            j    Fail_lb_1

    lb_test2:
            la   t0, mem_lb
            li   t1, -1
            sb   t1, 1(t0)
            lb   t2, 1(t0)
            li   t3, -1
            beq  t2, t3, lbu_test
            j    Fail_lb_2

    Fail_lb_1:
        li   gp, 1301
        j    fail

    Fail_lb_2:
        li   gp, 1302
        j    fail

lbu_test:
    lbu_test1:
            la   t0, mem_lb
            li   t1, -1
            sb   t1, 0(t0)
            lbu  t2, 0(t0)
            li   t3, 0xFF
            beq  t2, t3, lbu_test2
            j    Fail_lbu_1

    lbu_test2:
            la   t0, mem_lb
            li   t1, 0x80
            sb   t1, 1(t0)
            lbu  t2, 1(t0)
            li   t3, 0x80
            beq  t2, t3, lh_test
            j    Fail_lbu_2

    Fail_lbu_1:
        li   gp, 1401
        j    fail

    Fail_lbu_2:
        li   gp, 1402
        j    fail

lh_test:
    lh_test1:
            la   t0, mem_lh
            li   t1, 0x1234
            sh   t1, 0(t0)
            lh   t2, 0(t0)
            li   t3, 0x1234
            beq  t2, t3, lh_test2
            j    Fail_lh_1

    lh_test2:
            la   t0, mem_lh
            li   t1, -2
            sh   t1, 2(t0)
            lh   t2, 2(t0)
            li   t3, -2
            beq  t2, t3, lhu_test
            j    Fail_lh_2

    Fail_lh_1:
        li   gp, 1501
        j    fail

    Fail_lh_2:
        li   gp, 1502
        j    fail

lhu_test:
    lhu_test1:
            la   t0, mem_lh
            li   t1, 0xFFFF
            sh   t1, 0(t0)
            lhu  t2, 0(t0)
            li   t3, 0xFFFF
            beq  t2, t3, lhu_test2
            j    Fail_lhu_1

    lhu_test2:
            la   t0, mem_lh
            li   t1, 0x8000
            sh   t1, 2(t0)
            lhu  t2, 2(t0)
            li   t3, 0x8000
            beq  t2, t3, sb_test
            j    Fail_lhu_2

    Fail_lhu_1:
        li   gp, 1601
        j    fail

    Fail_lhu_2:
        li   gp, 1602
        j    fail

sb_test:
    sb_test1:
            la   t0, mem_sb
            li   t1, 0x7E
            sb   t1, 0(t0)
            lb   t2, 0(t0)
            li   t3, 0x7E
            beq  t2, t3, sb_test2
            j    Fail_sb_1

    sb_test2:
            la   t0, mem_sb
            li   t1, -1
            sb   t1, 1(t0)
            lb   t2, 1(t0)
            li   t3, -1
            beq  t2, t3, sh_test
            j    Fail_sb_2

    Fail_sb_1:
        li   gp, 1701
        j    fail

    Fail_sb_2:
        li   gp, 1702
        j    fail

sh_test:
    sh_test1:
            la   t0, mem_sh
            li   t1, 0x1234
            sh   t1, 0(t0)
            lh   t2, 0(t0)
            li   t3, 0x1234
            beq  t2, t3, sh_test2
            j    Fail_sh_1

    sh_test2:
            la   t0, mem_sh
            li   t1, -2
            sh   t1, 2(t0)
            lh   t2, 2(t0)
            li   t3, -2
            beq  t2, t3, bne_test
            j    Fail_sh_2

    Fail_sh_1:
        li   gp, 1801
        j    fail

    Fail_sh_2:
        li   gp, 1802
        j    fail

bne_test:
    bne_test1:
            li   t0, 5
            li   t1, 6
            bne  t0, t1, bne_test2
            j    Fail_bne_1

    bne_test2:
            li   t0, 7
            li   t1, 7
            bne  t0, t1, bne_fail_case
            j    blt_test

    bne_fail_case:
        li   gp, 1901
        j    fail

    Fail_bne_1:
        li   gp, 1902
        j    fail

blt_test:
    blt_test1:
            li   t0, -5
            li   t1, 3
            blt  t0, t1, blt_test2
            j    Fail_blt_1

    blt_test2:
            li   t0, 10
            li   t1, -1
            blt  t0, t1, blt_fail_case
            j    bltu_test

    blt_fail_case:
        li   gp, 2001
        j    fail

    Fail_blt_1:
        li   gp, 2002
        j    fail

bltu_test:
    bltu_test1:
            li   t0, 1
            li   t1, 2
            bltu t0, t1, bltu_test2
            j    Fail_bltu_1

    bltu_test2:
            li   t0, 0xFFFFFFFF
            li   t1, 0
            bltu t0, t1, bltu_fail_case
            j    bge_test

    bltu_fail_case:
        li   gp, 2101
        j    fail

    Fail_bltu_1:
        li   gp, 2102
        j    fail

bge_test:
    bge_test1:
            li   t0, 5
            li   t1, 5
            bge  t0, t1, bge_test2
            j    Fail_bge_1

    bge_test2:
            li   t0, 10
            li   t1, -1
            bge  t0, t1, bgeu_test
            j    bge_fail_case

    bge_fail_case:
        li   gp, 2201
        j    fail

    Fail_bge_1:
        li   gp, 2202
        j    fail

bgeu_test:
    bgeu_test1:
            li   t0, 2
            li   t1, 1
            bgeu t0, t1, bgeu_test2
            j    Fail_bgeu_1

    bgeu_test2:
            li   t0, 0
            li   t1, 0xFFFFFFFF
            bgeu t0, t1, bgeu_fail_case
            j    jalr_test

    bgeu_fail_case:
        li   gp, 2301
        j    fail

    Fail_bgeu_1:
        li   gp, 2302
        j    fail

jalr_test:
    jalr_test1:
            la   t0, jalr_target1
            addi t1, t0, -4      # expected reg address
            jalr t2, 0(t0)
            j    Fail_jalr_1

        jalr_target1:
            bne  t1, t2, Fail_jalr_1
            j    jalr_test2

    jalr_test2:
            la   t0, jalr_target2
            addi t1, t0, -4      # expected reg address
            jalr t2, 0(t0)
            j    Fail_jalr_2

        jalr_target2:
            bne  t1, t2, Fail_jalr_2
            j    lui_test

    Fail_jalr_1:
        li   gp, 2401
        j    fail

    Fail_jalr_2:
        li   gp, 2402
        j    fail

lui_test:
    lui_test1:
            li   t0, 0
            lui  t0, 0x12345         # t0 = 0x12345000
            li   t1, 0x12345000
            beq  t0, t1, lui_test2
            j    Fail_lui_1

    lui_test2:
            li   t0, 0
            lui  t0, 0xABCDE          # t0 = 0xABCDE000
            li   t1, 0xABCDE000
            beq  t0, t1, auipc_test
            j    Fail_lui_2

    Fail_lui_1:
        li   gp, 2501
        j    fail

    Fail_lui_2:
        li   gp, 2502
        j    fail

auipc_test:
    auipc_test1:
            auipc t0, 0x1             # t0 = PC + (0x1 << 12)
            auipc t1, 0x0             # load current PC into t1 for comparison

            addi  t1, t1, -4       # subtract 4 → now t1 = PC0

            lui   t2, 0x1          # t2 = 0x1000
            add   t1, t1, t2       # t1 = PC0 + 0x1000

            beq   t0, t1, auipc_test2
            j     Fail_auipc_1

    auipc_test2:
            auipc t0, 0xABCDE          # t0 = PC + (0xABCDE << 12)
            auipc t1, 0x0
            li    t2, 0xABCDE000       # expected offset only (approximate check)
            add   t1, t1, t2
            addi  t1, t1, -4
            beq   t0, t1, return_lab_test
            j     Fail_auipc_2

    Fail_auipc_1:
        li   gp, 2601
        j    fail

    Fail_auipc_2:
        li   gp, 2602
        j    fail


.section .data
# Memory area for load/store tests
mem_lb:    .byte 0x00, 0x00       # 2 bytes for lb/lbu tests
mem_lh:    .half 0x0000, 0x0000   # 4 bytes for lh/lhu tests
mem_sb:    .byte 0x00, 0x00       # 2 bytes for sb tests
mem_sh:    .half 0x0000, 0x0000   # 4 bytes for sh tests
