// ieu.sv

module ieu(
		// Inputs
        input   logic           clk, reset,
        input   logic [31:0]    InstrD,
        input   logic [31:0]    PCD,
		input	logic			RegWriteW, ResultSrcW, IEUResultW, ReadDataW, RdW,
		input 	logic			StallE, FlushE, 
		input	logic [1:0]		ForwardAE, ForwardBE,

		// Outputs
		output	logic	        RegWriteE, ResultSrcE, MemRWE,
		output	logic			IEUResultE,
		output	logic			IEUAdrE,
		output	logic 			FSrcBE,
		output	logic			Funct3E
		output	logic			RdE,

		// Todo set size, 
		// Todo check test bench inputs
        output  logic           PCSrc,
        output  logic [3:0]     WriteByteEn,
        output  logic [31:0]    IEUAdr, WriteData,
        input   logic [31:0]    ReadData,
        output  logic           MemEn
    );

    logic RegWrite, MemWrite, Jump, ALUResultSrc, ResultSrc,CSRSrc;
    logic [1:0] ALUSrc;
    logic [2:0] Flags;
    logic [2:0] ImmSrc;
    logic [4:0] ALUControl;

	logic [31:0] ImmExt;
    logic [31:0] R1, R2, SrcA, SrcB;
    logic [31:0] ALUResult, IEUResult, Result;
    logic [7:0]  ByteM;
    logic [15:0] HalfwordM;
    logic [31:0] LoadData;
    logic [31:0] CSRReadData, CSRResult;

    controller c(.Op(InstrD[6:0]), .Funct3(InstrD[14:12]), .Funct7(InstrD[31:25]), .Flags,
        .ALUResultSrc, .ResultSrc, .PCSrc,
        .ALUSrc, .RegWrite, .MemWrite, .ImmSrc, .ALUControl, .MemEn, .CSRSrc
    );

    // register file logic
    regfile rf(.clk, .WE3(RegWrite), .A1(InstrD[19:15]), .A2(InstrD[24:20]),
        .A3(InstrD[11:7]), .WD3(Result), .RD1(R1), .RD2(R2));

    //csrfile
    csrfile csr(.clk, .reset, .CSRWrite(CSRSrc), .CSRAdr(InstrD[31:20]),
        .RS1(R1), .RetiredInstr(~reset), .Op(InstrD[6:0]), .Funct3(InstrD[14:12]), .Funct7(InstrD[31:25]), .PCSrc,.CSRReadData);

    // extender chicken nuggets
    extend ext(.Instr(InstrD[31:7]), .ImmSrcD, .ImmExtD);

	// Execute Stage Pipeline Register 
	flopenrc #(_)  Rs1EReg(clk, reset, FlushE, ~StallE, 
	{RegWriteD, ResultSrcD, MemRWD, ALUResultSrcD, JumpD, ALUControlD, ALUSrcD},
	{RegWriteE, ResultSrcE, MemRWE, ALUResultSrcE, JumpE, ALUControlE, ALUSrcE});

	flopenrc #(32) RD1EReg(clk, reset, FlushE, ~StallE, PCD, PCE);

	flopenrc #(32) RD1EReg(clk, reset, FlushE, ~StallE, Rd1D, Rd1E);
  	flopenrc #(32) RD2EReg(clk, reset, FlushE, ~StallE, Rd2D, Rd2E);

	flopenrc #(5)  Rs1EReg(clk, reset, FlushE, ~StallE, ImmExtD, ImmExtE);
	flopenrc #(5)  Rs2EReg(clk, reset, FlushE, ~StallE, Funct3D, Funct3E);
	flopenrc #(5)  RdEReg(clk, reset, FlushE, ~StallE, RdD, RdE);


	//Datapath
	mux3 #(32) ieuresultmux(.Rd1E, .ResultW, .IEUResultM, .ForwardAE, .FSrcAE);
	mux3 #(32) ieuresultmux(.Rd2E, .ResultW, .IEUResultM, .ForwardBE, .FSrcBE);

    // Comparitor and ALU
    cmp cmp(.FSrcAE, .FSrcBE, .FlagsE);

    mux2 #(32) srcamux(FSrcAE, PCE, ALUSrcE[0], SrcAE); // TODO set the ALUSrcE toggle bits
    mux2 #(32) srcbmux(FSrcBE, ImmExtE, ALUSrcE[1], SrcBE);

    alu alu(.SrcAE, .SrcBE, .ALUControlE, .ALUResultE, .IEUAdrE);

	mux2 #(32) srcbmux(PCLinkE, ImmExtE, JumpE, AltResultE);
    mux2 #(32) srcbmux(ALUResultE, AltResultE, ALUResultSrcE, IEUResultE);
    mux2 #(32) srcbmux(IEUResultW, ReadDataW, ResultSrcW, ResultW);


    
endmodule
