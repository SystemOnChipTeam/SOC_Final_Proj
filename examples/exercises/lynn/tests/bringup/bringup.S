// C Runtime entry point
// James Kaden Cassidy
// kacassidy@hmc.edu
// 1/21/2026

.extern add_test
.extern or_test
.extern and_test
.extern sub_test
.extern sll_test
.extern srl_test
.extern sra_test
.extern sltu_test
.extern mem_test
.extern bne_test
.extern blt_test
.extern bge_test
.extern jalr_test
.extern lui_test
.extern auipc_test
.extern csrrs_test
.extern pass

    .section .text.init
    .globl main
    .globl return_add_test
    .globl return_or_test
    .globl return_and_test
    .globl return_sub_test
    .globl return_sll_test
    .globl return_srl_test
    .globl return_sra_test
    .globl return_sltu_test
    .globl return_mem_test
    .globl return_bne_test
    .globl return_blt_test
    .globl return_bge_test
    .globl return_jalr_test
    .globl return_lui_test
    .globl return_auipc_test
    .globl return_csrrs_test
    .type  main, @function

main:
    j add_test

return_add_test:
    j or_test

return_or_test:
    j and_test

return_and_test:
    j sub_test

return_sub_test:
    j sll_test

return_sll_test:
    j srl_test

return_srl_test:
    j sra_test

return_sra_test:
    j sltu_test

return_sltu_test:
    j mem_test

return_mem_test:
    j bne_test

return_bne_test:
    j blt_test

return_blt_test:
    j bge_test

return_bge_test:
    j jalr_test

return_jalr_test:
    j lui_test

return_lui_test:
    j auipc_test

return_auipc_test:
    j pass
