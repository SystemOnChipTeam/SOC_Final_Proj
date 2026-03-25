

module lsu(
		// Inputs
        input   logic           clk, reset,
		input	logic	        RegWriteE, ResultSrcE, MemRWE,
		input	logic			IEUResultE,
		input	logic			IEUAdrE,
		input	logic 			FSrcBE,
		input	logic			Funct3E,
		input	logic			RdE,
		input	logic			StallM, FlushM, StallW, FlushW,

		// Todo set size, 
		// Todo check test bench inputs
		// Outputs
        output  logic	        RegWriteW, ResultSrcW,
        output  logic     		IEUResultM, IEUResultW,
		output  logic     		ReadDataW,
        output  logic [31:0]    RdW,

		// DTIM Interface
		output  logic [31:0]    IEUAdrM,  // data memory target address
        input   logic [31:0]    ReadDataM, // data memory read data
        output  logic [31:0]    WriteDataM, // data memory write data

        output  logic           MemEn,
        output  logic           MemRWM,
        output  logic [3:0]     WriteByteEn  // strobes, 1 hot stating weather a byte should be written on a store
    );

	logic 			RegWriteM, ResultSrcM, MemRWM;
	logic	[31:0]	IEUResultM;
	logic			Funct3M, RdM;
	logic	[31:0]	DataOutM;
	
	// Memory Stage Pipeline Register 
	flopenrc #(32) RD1EReg(clk, reset, FlushM, ~StallM, RegWriteE, RegWriteM);
	flopenrc #(32) RD1EReg(clk, reset, FlushM, ~StallM, ResultSrcE, ResultSrcM);
	flopenrc #(32) RD1EReg(clk, reset, FlushM, ~StallM, MemRWE, MemRWM);

	flopenrc #(32) RD1EReg(clk, reset, FlushM, ~StallM, IEUResultE, IEUResultM);
	flopenrc #(32) RD1EReg(clk, reset, FlushM, ~StallM, IEUAdrE, IEUAdrM);
	flopenrc #(32) RD1EReg(clk, reset, FlushM, ~StallM, FSrcBE, FSrcBM);

	flopenrc #(32) RD1EReg(clk, reset, FlushM, ~StallM, Funct3E, Funct3M);
	flopenrc #(32) RD1EReg(clk, reset, FlushM, ~StallM, RdE, RdM);


	//DTIM Read and Write Logic

    // Subword Read — select and sign/zero extend based on Funct3 and address
    mux2 #(16) halfwordmux(ReadDataM[15:0], ReadDataM[31:16], IEUAdrM[1], HalfwordM);
    mux2 #(8)  bytemux(HalfwordM[7:0], HalfwordM[15:8],    IEUAdrM[0], ByteM);

    always_comb
        case (Funct3M)
            3'b000: DataOutM = {{24{ByteM[7]}},      ByteM};      // LB
            3'b001: DataOutM = {{16{HalfwordM[15]}}, HalfwordM};  // LH
            3'b010: DataOutM = ReadDataM;                           // LW
            3'b100: DataOutM = {24'b0, ByteM};                    // LBU
            3'b101: DataOutM = {16'b0, HalfwordM};                // LHU
            default: DataOutM = ReadDataM;
        endcase

    // Subword Write — replicate data into correct lanes
    always_comb
        case (Funct3M)
            3'b000: WriteDataM = {4{FSrcBM[7:0]}};  // SB — byte replicated to all lanes
            3'b001: WriteDataM = {2{FSrcBM[15:0]}}; // SH — half replicated to both halves
            3'b010: WriteDataM = FSrcBM;            // SW — full word
            default: WriteDataM = FSrcBM;
        endcase

    // Byte enables — gated by MemWrite, shifted by address offset
    always_comb
        if (!MemRWM) WriteByteEn = 4'b0000;
        else case (Funct3M)
            3'b000: WriteByteEn = 4'b0001 << IEUAdrM[1:0];        // SB — 1 byte at offset
            3'b001: WriteByteEn = 4'b0011 << {IEUAdrM[1], 1'b0};  // SH — 2 bytes at half offset
            3'b010: WriteByteEn = 4'b1111;                        // SW — all bytes
            default: WriteByteEn = 4'b1111;
        endcase


	// Writeback Stage Pipeline Register 
	flopenrc #(32) RD1EReg(clk, reset, FlushW, ~StallW, RegWriteM, RegWriteW);
	flopenrc #(32) RD1EReg(clk, reset, FlushW, ~StallW, ResultSrcM, ResultSrcW);

	flopenrc #(32) RD1EReg(clk, reset, FlushW, ~StallW, IEUResultM, IEUResultW);
	flopenrc #(32) RD1EReg(clk, reset, FlushW, ~StallW, DataOutM, ReadDataW);

	flopenrc #(32) RD1EReg(clk, reset, FlushW, ~StallW, RdM, RdW);

endmodule