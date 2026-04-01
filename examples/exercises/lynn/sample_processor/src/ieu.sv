// ieu.sv

module ieu(
		// Inputs Decode Stage
        input   logic           clk, reset,
        input   logic [31:0]    InstrD,
        input   logic [31:0]    PCD,
        input   logic [31:0]    PCPLus4D,

        // Outputs Execute Stage
		output	logic	        MemEnE, RegWriteE,
        output  logic [1:0]     ResultSrcE, 
        output  logic           MemWriteE,
		output	logic			ALUResultE,
		output	logic			WriteDataE,
		output	logic			Funct3E
        output  logic [31:0]    PCPlus4E,

        // Inputs Writeback Stage
        input   logic           RegWriteW, 
        input   logic [1:0]     ResultSrcW,
        input   logic [31:0]    ALUResultW,
        input   logic [31:0]    ReadDataW,
        input   logic [31:0]    PCPlus4W,
        input   logic [4:0]     RdW,

        // Outputs Writeback Stage
        output  logic [31:0]    ResultW,

        // Hazard Unit Decode Stage Interface
        output	logic [4:0]		Rs1D, Rs2D,
        output	logic [4:0]		InstrD,

        // Hazard Unit Execute Stage Interface
		input 	logic			StallE, FlushE, 
		input	logic [1:0]		ForwardAE, ForwardBE,
		output	logic [4:0]		Rs1E, Rs2E, RdE, 
		output	logic			PCSrcE, // 1 if branch is taken
		output	logic 			ResultSrcE0, // 1 if lw is in execute stage
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

    // TODO: fix instantiations and connections
    // Control logic
    controller c(.Op(InstrD[6:0]), .Funct3(InstrD[14:12]), .Funct7(InstrD[31:25]), .Flags,
        .ALUResultSrc, .ResultSrc, .PCSrc,
        .ALUSrc, .RegWrite, .MemWrite, .ImmSrc, .ALUControl, .MemEn, .CSRSrc
    );

    // Register file logic
    regfile rf(.clk, .WE3(RegWrite), .A1(InstrD[19:15]), .A2(InstrD[24:20]),
        .A3(InstrD[11:7]), .WD3(Result), .RD1(R1), .RD2(R2));

    // TODO: keep this?
    // //csrfile
    // csrfile csr(.clk, .reset, .CSRWrite(CSRSrc), .CSRAdr(InstrD[31:20]),
    //     .RS1(R1), .RetiredInstr(~reset), .Op(InstrD[6:0]), .Funct3(InstrD[14:12]), .Funct7(InstrD[31:25]), .PCSrc,.CSRReadData);

    // extender blender chicken nuggets remember
    extend ext(.Instr(InstrD[31:7]), .ImmSrcD, .ImmExtD);

	// Pipeline Register E-Stage 
	flopenrc #(_)  Rs1EReg(clk, reset, FlushE, ~StallE, 
	{RegWriteD, ResultSrcD, MemRWD, ALUResultSrcD, JumpD, ALUControlD, ALUSrcD},
	{RegWriteE, ResultSrcE, MemRWE, ALUResultSrcE, JumpE, ALUControlE, ALUSrcE});

	flopenrc #(32) RD1EReg(clk, reset, FlushE, ~StallE, PCD, PCE);

	flopenrc #(32) RD1EReg(clk, reset, FlushE, ~StallE, Rd1D, Rd1E);
  	flopenrc #(32) RD2EReg(clk, reset, FlushE, ~StallE, Rd2D, Rd2E);

	flopenrc #(5)  Rs1EReg(clk, reset, FlushE, ~StallE, ImmExtD, ImmExtE);
	flopenrc #(5)  Rs2EReg(clk, reset, FlushE, ~StallE, Funct3D, Funct3E);
	flopenrc #(5)  RdEReg(clk, reset, FlushE, ~StallE, RdD, RdE);

	// Datapath
	mux3 #(32) ieuresultmux(.Rd1E, .ResultW, .IEUResultM, .ForwardAE, .FSrcAE);
	mux3 #(32) ieuresultmux(.Rd2E, .ResultW, .IEUResultM, .ForwardBE, .FSrcBE);

    // Comparitor and ALU
    cmp cmp(.FSrcAE, .FSrcBE, .FlagsE);

    mux2 #(32) srcamux(FSrcAE, PCE, ALUSrcE[0], SrcAE); // TODO set the ALUSrcE toggle bits
    mux2 #(32) srcbmux(FSrcBE, ImmExtE, ALUSrcE[1], SrcBE);

    alu alu(.SrcAE, .SrcBE, .ALUControlE, .ALUResultE, .IEUAdrE);

    adder pcadder(PCE, ImmExtE, PCTargetE);

    // TODO: Branch Logic Block
    logic BranchTaken;
    case (Funct3)
                    3'b000: BranchTaken = FlagsE[0];   // BEQ  — equal
                    3'b001: BranchTaken = ~FlagsE[0];  // BNE  — not equal
                    3'b100: BranchTaken = FlagsE[1];   // BLT  — signed less than
                    3'b101: BranchTaken = ~FlagsE[1];  // BGE  — signed greater or equal (not less than)
                    3'b110: BranchTaken = FlagsE[2];   // BLTU — unsigned less than
                    3'b111: BranchTaken = ~FlagsE[2];  // BGEU — unsigned greater or equal (not less than)
                    default: BranchTaken = 1'b0;
    endcase

    assign PCSrcE = (BranchE & BranchTaken) | JumpE;

    
endmodule
