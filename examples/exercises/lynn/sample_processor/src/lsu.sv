// lsu.sv
// RISC-V pipelined processor
// pclark@hmc.edu mconine@hmc.edu 2026

module lsu(
		// Inputs
        input   logic           clk, reset,
        input   logic           MemEnE,
		input	logic	        RegWriteE,
        input	logic   [1:0]	ResultSrcE, 
        input	logic           MemWriteE,
		input   logic   [31:0]  ALUResultE,
        input   logic   [31:0]  WriteDataE,
        input   logic   [4:0]   RdE,
        input   logic   [31:0]  PCPlus4E,
        input   logic   [2:0]   Funct3E,

        // Hazard Unit interface
        input	logic			StallM, FlushM, StallW, FlushW,
        output	logic [4:0]		RdM,
		output	logic 			RegWriteM,
        
		// Outputs
        output  logic	        RegWriteW, 
        output  logic   [1:0]   ResultSrcW,
        output  logic   [31:0]  ALUResultW, ReadDataW, PCPlus4W,
        output  logic   [4:0]   RdW,


		// DTIM Interface
		output  logic   [31:0]  ALUResultM,  // data memory target address
        input   logic   [31:0]  DataOutM, // data memory read data
        output  logic   [31:0]  DataInM, // data memory write data

        output  logic           MemEnM, MemWriteM,
        output  logic   [3:0]   WriteByteEn  // strobes, 1 hot stating weather a byte should be written on a store
    );

    // Declare internal signals
    logic   [1:0]   ResultSrcM;
	logic	[31:0]	WriteDataM, ReadDataM, PCPlus4M;
	logic	[2:0]   Funct3M;
	
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

    // Subword Write — replicate data into correct lanes
    always_comb
        case (Funct3M)
            3'b000: DataInM = {4{WriteDataM[7:0]}};  // SB — byte replicated to all lanes
            3'b001: DataInM = {2{WriteDataM[15:0]}}; // SH — half replicated to both halves
            3'b010: DataInM = WriteDataM;            // SW — full word
            default: DataInM = WriteDataM;
        endcase

    // Byte enables — gated by MemWrite, shifted by address offset
    always_comb
        if (!MemWriteM) WriteByteEn = 4'b0000;
        else case (Funct3M)
            3'b000: WriteByteEn = 4'b0001 << ALUResultM[1:0];        // SB — 1 byte at offset
            3'b001: WriteByteEn = 4'b0011 << {ALUResultM[1], 1'b0};  // SH — 2 bytes at half offset
            3'b010: WriteByteEn = 4'b1111;                        // SW — all bytes
            default: WriteByteEn = 4'b1111;
        endcase


	// Writeback Stage Pipeline Register 
	flopenrc #(1)  RegWriteWReg (clk, reset, FlushW, ~StallW, RegWriteM, RegWriteW);
    flopenrc #(2)  ResultSrcWReg(clk, reset, FlushW, ~StallW, ResultSrcM,ResultSrcW);
    flopenrc #(32) ALUResultWReg(clk, reset, FlushW, ~StallW, ALUResultM,ALUResultW);
    flopenrc #(32) ReadDataWReg (clk, reset, FlushW, ~StallW, ReadDataM, ReadDataW);
    flopenrc #(5)  RdWReg       (clk, reset, FlushW, ~StallW, RdM,       RdW);
    flopenrc #(32) PCPlus4WReg  (clk, reset, FlushW, ~StallW, PCPlus4M,  PCPlus4W);

endmodule