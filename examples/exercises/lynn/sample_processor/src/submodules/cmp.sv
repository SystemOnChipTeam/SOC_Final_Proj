// RISC-V pipelined processor
// pclark@hmc.edu mconine@hmc.edu 2026

module cmp(
        input   logic [31:0]    SrcA, SrcB,
        output  logic [2:0]     Flags
    );

    // Flags[0] = Eq  — SrcA == SrcB
    // Flags[1] = LT  — SrcA <  SrcB (signed)
    // Flags[2] = LTU — SrcA <  SrcB (unsigned)

    assign Flags[0] = (SrcA == SrcB);
    assign Flags[1] = ($signed(SrcA) < $signed(SrcB));
    assign Flags[2] = (SrcA < SrcB);

endmodule
