// subwordread.sv
// Subword extraction and sign extension for RV32 loads
// Simplified from CORE-V-WALLY reference for RV32I (LLEN=32)
// Uses address bit muxes to select byte/half, matching ram1p1rwb word-addressed output

module subwordread (
    input  logic [31:0] ReadDataWord,  // full word from data memory
    input  logic [1:0]  PAdr,          // byte address offset (IEUAdr[1:0])
    input  logic [2:0]  Funct3,        // load type
    output logic [31:0] ReadData
);

    logic [7:0]  ByteM;
    logic [15:0] HalfwordM;

    // Select halfword using address bit 1, then byte using address bit 0
    // Mirrors the mux chain in the WALLY reference
    mux2 #(16) halfwordmux(ReadDataWord[15:0], ReadDataWord[31:16], PAdr[1], HalfwordM);
    mux2 #(8)  bytemux(HalfwordM[7:0], HalfwordM[15:8], PAdr[0], ByteM);

    // Sign/zero extend
    always_comb
        case (Funct3)
            3'b000: ReadData = {{24{ByteM[7]}},     ByteM};        // LB
            3'b001: ReadData = {{16{HalfwordM[15]}}, HalfwordM};   // LH
            3'b010: ReadData = ReadDataWord;                        // LW
            3'b100: ReadData = {24'b0, ByteM};                     // LBU
            3'b101: ReadData = {16'b0, HalfwordM};                 // LHU
            default: ReadData = ReadDataWord;
        endcase

endmodule
