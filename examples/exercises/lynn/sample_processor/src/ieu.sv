// ieu.sv
// RISC-V pipelined processor
// pclark@hmc.edu mconine@hmc.edu 2026

module ieu(
        // Inputs Decode Stage
        input   logic           clk, reset,
        input   logic [31:0]    InstrD,
        input   logic [31:0]    PCD,
        input   logic [31:0]    PCPlus4D,

        // Outputs Execute Stage
        output  logic           MemEnE, RegWriteE,
        output  logic [1:0]     ResultSrcE,
        output  logic           MemWriteE,
        output  logic [31:0]    ALUResultE,
        output  logic [31:0]    WriteDataE,
        output  logic [2:0]     Funct3E,
        output  logic [31:0]    PCPlus4E,
        output  logic [31:0]    PCTargetE,

        // Inputs Memory Stage
        input logic [31:0] ALUResultM,

        // Inputs Writeback Stage
        input   logic           RegWriteW,
        input   logic [1:0]     ResultSrcW,
        input   logic [31:0]    ALUResultW,
        input   logic [31:0]    ReadDataW,
        input   logic [31:0]    PCPlus4W,
        input   logic [4:0]     RdW,
        input   logic [31:0]    PCTargetW,

        // Hazard Unit Decode Stage Interface
        output  logic [4:0]     Rs1D, Rs2D,

        // Hazard Unit Execute Stage Interface
        input   logic           StallE, FlushE,
        input   logic [1:0]     ForwardAE, ForwardBE,
        output  logic [4:0]     Rs1E, Rs2E, RdE,
        output  logic           PCSrcE,
        output  logic           ResultSrcE0
    );

    // Decode Stage internal signals
    // Controller outputs (D-Stage)
    logic        MemEnD, RegWriteD, MemWriteD;
    logic [1:0]  ResultSrcD;
    logic        JumpD, BranchD, ALUSrcD;
    logic [4:0]  ALUControlD;
    logic [2:0]  ImmSrcD;

    // Detect JALR in decode stage based on opcode
    logic        JalrD;
    assign JalrD = (InstrD[6:0] == 7'b1100111);

    // Datapath (D-stage)
    logic [31:0] Rd1D, Rd2D, ImmExtD;

    // Execute Stage internal signals
    logic [31:0] Rd1E, Rd2E, PCE, ImmExtE;
    logic        JumpE, BranchE, ALUSrcE, JalrE;
    logic [4:0]  ALUControlE;
    logic [31:0] SrcAE, SrcBE;
    logic [2:0]  FlagsE;
    logic        BranchTaken;
    logic [31:0] BranchTargetE;

    // Writeback Stage internal signals
    logic [31:0] ResultW;

    // Combinational assignments
    assign ResultSrcE0 = ResultSrcE[0];
    assign Rs1D = InstrD[19:15];
    assign Rs2D = InstrD[24:20];

    logic  CSRSrcD;

    controller c(.clk, .reset, .InstrD, .MemEnD, .RegWriteD, .ResultSrcD, .MemWriteD, .JumpD, .BranchD, .ALUControlD, .ALUSrcD, .ImmSrcD, .CSRSrcD);

    // Register file logic
    regfile rf(.clk, .WE3(RegWriteW), .A1(InstrD[19:15]), .A2(InstrD[24:20]),
        .A3(RdW), .WD3(ResultW), .RD1(Rd1D), .RD2(Rd2D));

    // extender
    extend ext(.Instr(InstrD[31:7]), .ImmSrc(ImmSrcD), .ImmExt(ImmExtD));

    // Pipeline Register E-Stage
    // Controller registers
    flopenrc #(1) MemEnEReg    (clk, reset, FlushE, ~StallE, MemEnD,     MemEnE);
    flopenrc #(1) RegWriteEReg (clk, reset, FlushE, ~StallE, RegWriteD,  RegWriteE);
    flopenrc #(2) ResultSrcEReg(clk, reset, FlushE, ~StallE, ResultSrcD, ResultSrcE);
    flopenrc #(1) MemWriteEReg (clk, reset, FlushE, ~StallE, MemWriteD,  MemWriteE);
    flopenrc #(1) JumpEReg     (clk, reset, FlushE, ~StallE, JumpD,      JumpE);
    flopenrc #(1) BranchEReg   (clk, reset, FlushE, ~StallE, BranchD,    BranchE);
    flopenrc #(5) ALUControlEReg(clk, reset, FlushE, ~StallE, ALUControlD, ALUControlE);
    flopenrc #(1) ALUSrcEReg   (clk, reset, FlushE, ~StallE, ALUSrcD,    ALUSrcE);
    flopenrc #(1) JalrEReg     (clk, reset, FlushE, ~StallE, JalrD,      JalrE);

    // Datapath registers
    flopenrc #(32) RD1EReg(clk, reset, FlushE, ~StallE, Rd1D, Rd1E);
    flopenrc #(32) RD2EReg(clk, reset, FlushE, ~StallE, Rd2D, Rd2E);
    flopenrc #(32) PCEReg(clk, reset, FlushE, ~StallE, PCD, PCE);
    flopenrc #(5)  Rs1EReg(clk, reset, FlushE, ~StallE, InstrD[19:15], Rs1E);
    flopenrc #(5)  Rs2EReg(clk, reset, FlushE, ~StallE, InstrD[24:20], Rs2E);
    flopenrc #(5)  RdEReg(clk, reset, FlushE, ~StallE, InstrD[11:7], RdE);

    flopenrc #(32) ImmExtEReg(clk, reset, FlushE, ~StallE, ImmExtD, ImmExtE);
    flopenrc #(32) PCPlus4EReg(clk, reset, FlushE, ~StallE, PCPlus4D, PCPlus4E);
    flopenrc #(3)  Funct3EReg(clk, reset, FlushE, ~StallE, InstrD[14:12], Funct3E);

    // Datapath
    // FIXED: Swapped ALUResultM and ResultW.
    // 00 = Rd (Decode), 01 = ResultW (Writeback), 10 = ALUResultM (Memory)
    mux3 #(32) ForwardmuxA(Rd1E, ResultW, ALUResultM, ForwardAE, SrcAE);
    mux3 #(32) ForwardmuxB(Rd2E, ResultW, ALUResultM, ForwardBE, WriteDataE);

    // Comparator and ALU
    mux2 #(32) srcbmux(WriteDataE, ImmExtE, ALUSrcE, SrcBE);
    cmp comparator(.SrcA(SrcAE), .SrcB(SrcBE), .Flags(FlagsE));
    alu alu(SrcAE, SrcBE, ALUControlE, ALUResultE);

    // Branch/Jump Target Logic
    adder pcadder(PCE, ImmExtE, BranchTargetE);

    // Select ALUResult for JALR, otherwise normal Branch/JAL target
    assign PCTargetE = JalrE ? (ALUResultE & 32'hFFFFFFFE) : BranchTargetE;

    always_comb
        case (Funct3E)
            3'b000: BranchTaken = FlagsE[0];   // BEQ
            3'b001: BranchTaken = ~FlagsE[0];  // BNE
            3'b100: BranchTaken = FlagsE[1];   // BLT
            3'b101: BranchTaken = ~FlagsE[1];  // BGE
            3'b110: BranchTaken = FlagsE[2];   // BLTU
            3'b111: BranchTaken = ~FlagsE[2];  // BGEU
            default: BranchTaken = 1'b0;
        endcase

    // Force PCSrcE high if a JALR, JAL, or taken Branch is executing
    assign PCSrcE = (BranchE & BranchTaken) | JumpE | JalrE;

    // Writeback mux
    mux4 #(32) resultmux(ALUResultW, ReadDataW, PCPlus4W, PCTargetW, ResultSrcW, ResultW);

endmodule
