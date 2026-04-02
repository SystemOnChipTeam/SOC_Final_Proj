// lsu.sv
// RISC-V pipelined processor
// pclark@hmc.edu mconine@hmc.edu 2026

module lsu(
        // Inputs
        input   logic           clk, reset,
        input   logic           MemEnE,     // Memory enable
        input   logic           RegWriteE,  // Register file write enable
        input   logic   [1:0]   ResultSrcE, // Result source selector
        input   logic           MemWriteE,  // Memory write enable
        input   logic   [31:0]  ALUResultE, // ALU result
        input   logic   [31:0]  WriteDataE, // Data to write to memory
        input   logic   [4:0]   RdE,        // Destination register
        input   logic   [31:0]  PCPlus4E,   // PC+4 value
        input   logic   [2:0]   Funct3E,    // Function 3 field
        input   logic   [31:0]  PCTargetE,  // Branch target address

        // Hazard Unit interface
        input   logic StallM, FlushM, StallW, FlushW, // stall and flush signals for M and W stages
        output  logic [4:0] RdM,                      // destination register in Memory stage
        output  logic RegWriteM,                      // register file write enable in Memory stage

        // Outputs
        output  logic         RegWriteW,                         // register file write enable in Writeback stage
        output  logic   [1:0]   ResultSrcW,                      // Result source selector in Writeback stage
        output  logic   [31:0]  ALUResultW, ReadDataW, PCPlus4W, // ALU result, memory read data, and PC+4 value in Writeback stage
        output  logic   [4:0]   RdW,                             // Destination register in Writeback stage
        output logic    [31:0]  PCTargetW,                       // Branch target address in Writeback stage

        // DTIM Interface
        output  logic   [31:0]  ALUResultM,  // Data memory target address
        input   logic   [31:0]  DataOutM,    // Data memory read data
        output  logic   [31:0]  DataInM,     // Data memory write data

        output  logic           MemEnM, MemWriteM, // Memory enable and write enable in Memory stage
        output  logic   [3:0]   WriteByteEn        // Byte enable signals for memory writes
    );

    // Declare internal signals
    logic   [1:0]   ResultSrcM;                      // Result source selector in Memory stage
    logic   [31:0]  WriteDataM, ReadDataM, PCPlus4M; // Data to write to memory, data read from memory, and PC+4 value in Memory stage
    logic   [2:0]   Funct3M;                         // Function 3 field in Memory stage
    logic   [31:0]  PCTargetM;                       // Branch target address in Memory stage

    // Pipeline Register M-Stage
    flopenrc #(1)  MemEnMReg    (clk, reset, FlushM, ~StallM, MemEnE,    MemEnM);
    flopenrc #(1)  RegWriteMReg (clk, reset, FlushM, ~StallM, RegWriteE, RegWriteM);
    flopenrc #(2)  ResultSrcMReg(clk, reset, FlushM, ~StallM, ResultSrcE,ResultSrcM);
    flopenrc #(1)  MemWriteMReg (clk, reset, FlushM, ~StallM, MemWriteE, MemWriteM);
    flopenrc #(32) ALUResultMReg(clk, reset, FlushM, ~StallM, ALUResultE,ALUResultM);
    flopenrc #(32) WriteDataMReg(clk, reset, FlushM, ~StallM, WriteDataE,WriteDataM);
    flopenrc #(3)  Funct3MReg   (clk, reset, FlushM, ~StallM, Funct3E,   Funct3M);
    flopenrc #(5)  RdMReg       (clk, reset, FlushM, ~StallM, RdE,       RdM);
    flopenrc #(32) PCPlus4MReg  (clk, reset, FlushM, ~StallM, PCPlus4E,  PCPlus4M);
    flopenrc #(32) PCTargetMReg(clk, reset, FlushM, ~StallM, PCTargetE, PCTargetM);


    //DTIM Read and Write Logic
    logic [15:0]    HalfwordM;
    logic [7:0]     ByteM;

    // Subword Read — select and sign/zero extend based on Funct3 and address
    mux2 #(16) halfwordmux(DataOutM[15:0], DataOutM[31:16], ALUResultM[1], HalfwordM);
    mux2 #(8)  bytemux(HalfwordM[7:0], HalfwordM[15:8],    ALUResultM[0], ByteM);

    always_comb
        case (Funct3M)
            3'b000: ReadDataM = {{24{ByteM[7]}},      ByteM};      // LB
            3'b001: ReadDataM = {{16{HalfwordM[15]}}, HalfwordM};  // LH
            3'b010: ReadDataM = DataOutM;                           // LW
            3'b100: ReadDataM = {24'b0, ByteM};                    // LBU
            3'b101: ReadDataM = {16'b0, HalfwordM};                // LHU
            default: ReadDataM = DataOutM;
        endcase

    // Subword Write
    always_comb
        case (Funct3M)
            3'b000: DataInM = {4{WriteDataM[7:0]}};  // SB — byte replicated to all lanes
            3'b001: DataInM = {2{WriteDataM[15:0]}}; // SH — half replicated to both halves
            3'b010: DataInM = WriteDataM;            // SW — full word
            default: DataInM = WriteDataM;
        endcase

    // Byte enables
    always_comb
        if (!MemWriteM) WriteByteEn = 4'b0000;
        else case (Funct3M)
            3'b000: WriteByteEn = 4'b0001 << ALUResultM[1:0];// SB — 1 byte at offset
            3'b001: WriteByteEn = 4'b0011 << {ALUResultM[1], 1'b0};  // SH — 2 bytes at half offset
            3'b010: WriteByteEn = 4'b1111; // SW — all bytes
            default: WriteByteEn = 4'b1111;
        endcase

    // Writeback Stage Pipeline Register
    flopenrc #(1)  RegWriteWReg (clk, reset, FlushW, ~StallW, RegWriteM, RegWriteW);
    flopenrc #(2)  ResultSrcWReg(clk, reset, FlushW, ~StallW, ResultSrcM,ResultSrcW);
    flopenrc #(32) ALUResultWReg(clk, reset, FlushW, ~StallW, ALUResultM,ALUResultW);
    flopenrc #(32) ReadDataWReg (clk, reset, FlushW, ~StallW, ReadDataM, ReadDataW);
    flopenrc #(5)  RdWReg       (clk, reset, FlushW, ~StallW, RdM, RdW);
    flopenrc #(32) PCPlus4WReg  (clk, reset, FlushW, ~StallW, PCPlus4M,  PCPlus4W);
    flopenrc #(32) PCTargetWReg(clk, reset, FlushW, ~StallW, PCTargetM, PCTargetW);

endmodule
