// regfile.sv
// RISC-V pipelined processor

module regfile(
        input   logic           clk,
        input   logic           WE3,
        input   logic [4:0]     A1, A2, A3,
        input   logic [31:0]    WD3,
        output  logic [31:0]    RD1, RD2
    );

    logic [31:0] rf[31:1];

    // Write on rising edge of clock (protect against writing to x0)
    always_ff @(posedge clk) begin
        if (WE3 && A3 != 5'b0) rf[A3] <= WD3;
    end

    // Internal Forwarding: Read new data if writing to the same register this cycle
    assign RD1 = (A1 == 5'b0) ? 32'b0 :
                 ((A1 == A3) && WE3) ? WD3 :
                 rf[A1];

    assign RD2 = (A2 == 5'b0) ? 32'b0 :
                 ((A2 == A3) && WE3) ? WD3 :
                 rf[A2];

endmodule
