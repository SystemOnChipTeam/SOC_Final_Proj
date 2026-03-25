// riscvsingle.sv
// RISC-V single-cycle processor
// mconine@g.hmc.edu

module mux3 #(parameter WIDTH = 8) (
        input   logic [WIDTH-1:0]   A,
        input   logic [WIDTH-1:0]   B,
        input   logic [WIDTH-1:0]   C,
        input   logic [1:0]         select,

        output  logic [WIDTH-1:0]   result
    );

    always_comb
        case(select)
            2'b00:   result = A;
            2'b01:   result = B;
            2'b10:   result = C;
            default: result = {WIDTH{1'bx}}; // Helpful for debugging
        endcase

endmodule
