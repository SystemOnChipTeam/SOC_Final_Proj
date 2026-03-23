// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020

module cmp(
        input   logic [31:0]    R1, R2,
        output  logic [2:0]     Flags
    );

    // Flags[0] = Eq  — R1 == R2
    // Flags[1] = LT  — R1 <  R2 (signed)
    // Flags[2] = LTU — R1 <  R2 (unsigned)
    assign Flags[0] = (R1 == R2);
    assign Flags[1] = ($signed(R1) < $signed(R2));
    assign Flags[2] = (R1 < R2);


endmodule
