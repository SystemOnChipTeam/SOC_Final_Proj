// ieu.sv
// RISC-V pipelined processor
// Max Conine and Pierce Clark
// pclark@hmc.edu mconine@hmc.edu 2026

module ieu(
        // Decode Stage Inputs
        input   logic           clk, reset,
        input   logic [31:0]    InstrD,     // 32-bit instruction
        input   logic [31:0]    PCD,        // Program Counter
        input   logic [31:0]    PCPlus4D,   // PC + 4

        // Execute Stage Outputs
        output  logic           MemEnE,     // Memory access enable
        output  logic           RegWriteE,  // Register file write enable
        output  logic           MemWriteE,  // Data memory write enable
        output  logic [31:0]    ALUResultE, // ALU result or memory address
        output  logic [31:0]    WriteDataE, // Data to store in memory
        output  logic [2:0]     Funct3E,    // funct3 for memory/branch ops

        // Memory Stage Inputs
        input logic [31:0]      ALUResultM, // Forwarded ALU result from M

        // Writeback Stage Inputs
        input   logic           RegWriteW,  // Writeback register write enable
        input   logic [31:0]    ALUResultW, // Forwarded ALU result from W
        input   logic [31:0]    ReadDataW,  // Forwarded memory data from W
        input   logic [4:0]     RdW,        // Writeback destination register

        // Hazard Unit Decode Stage Interface
        output  logic [4:0]     Rs1D, Rs2D, // Source regs for stall detection

        // Hazard Unit Execute Stage Interface
        input   logic           StallE, FlushE, StallM, FlushM, StallW, FlushW, // Stall and flush signals from hazard unit
        input   logic [1:0]     ForwardAE, ForwardBE, // Forwarding mux selects
        output  logic [4:0]     Rs1E, Rs2E, RdE,      // Registers for forwarding logic

        // Branch Prediction Interface
        output  logic           PredictTakenD,        // Prediction made in Decode
        output  logic [31:0]    PredictedTargetD,     // Predicted target address in Decode
        output  logic           MispredictE,          // Flag if prediction was wrong in Execute
        output  logic [31:0]    RecoveryPCE,          // Correct PC to recover to if mispredicted

        output  logic           ResultSrcE0,          // Load instruction flag (ResultSrc[0])
        output  logic           MulWorking            // Whether we are currently processing a multiply instruction in execute stage
    );

    // Decode Stage internal signals
    logic        MemEnD, RegWriteD, MemWriteD;
    logic [1:0]  ResultSrcD, ResultSrcE;
    logic        JumpD, BranchD, ALUSrcD;
    logic [3:0]  ALUControlD;
    logic [2:0]  ImmSrcD;
    logic [31:0] PCPlus4E;

    // Datapath (D-stage) wires
    logic [31:0] Rd1D, Rd2D, ImmExtD;
    logic        CSRSrcD;
    logic [31:0] CSRReadDataD;
    logic        IsMulD;

    // Detect JALR in decode stage based on opcode
    logic        JalrD;
    assign JalrD = (InstrD[6:0] == 7'b1100111);

    // Combinational assignments
    assign ResultSrcE0 = ResultSrcE[0];
    assign Rs1D = InstrD[19:15];
    assign Rs2D = InstrD[24:20];

    // Shared Decode Data (Multiplex ImmExtD and CSRReadDataD)
    logic [31:0] SharedDataD;
    assign SharedDataD = CSRSrcD ? CSRReadDataD : ImmExtD;

    // Predict branches taken if offset is negative (ImmExtD[31]).
    // Predict JAL (JumpD & ~JalrD) as always taken.
    assign PredictedTargetD = PCD + ImmExtD;
    assign PredictTakenD = (BranchD & ImmExtD[31]) | (JumpD & ~JalrD);

    // Pipeline Register for Prediction
    logic PredictTakenE;
    flopenrc #(1) PredictTakenEReg (clk, reset, FlushE, ~StallE, PredictTakenD, PredictTakenE);

    // Execute Stage internal signals
    logic [31:0] Rd1E, Rd2E, PCE, SharedDataE;
    logic        JumpE, BranchE, ALUSrcE, JalrE;
    logic [3:0]  ALUControlE;
    logic [31:0] SrcAE, SrcBE;
    logic [2:0]  FlagsE;
    logic        BranchTaken;
    logic [31:0] BranchTargetE;
    logic [31:0] PCTargetE; // Moved from output port to internal logic
    logic [31:0] ProdE;
    logic        IsMulE;
    logic        CSRSrcE;

    // Writeback
    logic [31:0] ResultW;

    // Decode Stage Modules
    controller c(.clk, .reset, .InstrD, .MemEnD, .RegWriteD, .ResultSrcD, .MemWriteD, .JumpD, .BranchD, .ALUControlD, .ALUSrcD, .ImmSrcD, .CSRSrcD, .IsMulD);

    csrfile csr(.clk(clk), .reset(reset), .CSRAdr(InstrD[31:20]), .RetiredInstr(~StallE & ~FlushE), .CSRReadData(CSRReadDataD));

    regfile rf(.clk, .WE3(RegWriteW), .A1(InstrD[19:15]), .A2(InstrD[24:20]), .A3(RdW), .WD3(ResultW), .RD1(Rd1D), .RD2(Rd2D));

    extend ext(.Instr(InstrD[31:7]), .ImmSrc(ImmSrcD), .ImmExt(ImmExtD));

    // Pipeline Registers (D -> E)
    flopenrc #(1)  IsMulEReg      (clk, reset, FlushE, ~StallE, IsMulD,      IsMulE);
    flopenrc #(1)  MemEnEReg      (clk, reset, FlushE, ~StallE, MemEnD,      MemEnE);
    flopenrc #(1)  RegWriteEReg   (clk, reset, FlushE, ~StallE, RegWriteD,   RegWriteE);
    flopenrc #(2)  ResultSrcEReg  (clk, reset, FlushE, ~StallE, ResultSrcD,  ResultSrcE);
    flopenrc #(1)  MemWriteEReg   (clk, reset, FlushE, ~StallE, MemWriteD,   MemWriteE);
    flopenrc #(1)  JumpEReg       (clk, reset, FlushE, ~StallE, JumpD,       JumpE);
    flopenrc #(1)  BranchEReg     (clk, reset, FlushE, ~StallE, BranchD,     BranchE);
    flopenrc #(4)  ALUControlEReg (clk, reset, FlushE, ~StallE, ALUControlD, ALUControlE);
    flopenrc #(1)  ALUSrcEReg     (clk, reset, FlushE, ~StallE, ALUSrcD,     ALUSrcE);
    flopenrc #(1)  JalrEReg       (clk, reset, FlushE, ~StallE, JalrD,       JalrE);
    flopenrc #(1)  CSRSrcEReg     (clk, reset, FlushE, ~StallE, CSRSrcD,     CSRSrcE);

    // Datapath registers
    flopenrc #(32) RD1EReg        (clk, reset, FlushE, ~StallE, Rd1D, Rd1E);
    flopenrc #(32) RD2EReg        (clk, reset, FlushE, ~StallE, Rd2D, Rd2E);
    flopenrc #(32) PCEReg         (clk, reset, FlushE, ~StallE, PCD, PCE);
    flopenrc #(5)  Rs1EReg        (clk, reset, FlushE, ~StallE, InstrD[19:15], Rs1E);
    flopenrc #(5)  Rs2EReg        (clk, reset, FlushE, ~StallE, InstrD[24:20], Rs2E);
    flopenrc #(5)  RdEReg         (clk, reset, FlushE, ~StallE, InstrD[11:7], RdE);

    // The new shared 32-bit register replaces ImmExtEReg and CSRReadDataEReg
    flopenrc #(32) SharedDataEReg (clk, reset, FlushE, ~StallE, SharedDataD, SharedDataE);

    flopenrc #(32) PCPlus4EReg    (clk, reset, FlushE, ~StallE, PCPlus4D, PCPlus4E);
    flopenrc #(3)  Funct3EReg     (clk, reset, FlushE, ~StallE, InstrD[14:12], Funct3E);

    // Datapath Forwarding & Execute Stage
    mux3 #(32) ForwardmuxA(Rd1E, ResultW, ALUResultM, ForwardAE, SrcAE);
    mux3 #(32) ForwardmuxB(Rd2E, ResultW, ALUResultM, ForwardBE, WriteDataE);
    mux2 #(32) srcbmux(WriteDataE, SharedDataE, ALUSrcE, SrcBE);

    // Execute stage modules
    logic [31:0] ALUResult_Raw;
    cmp comparator(.SrcA(SrcAE), .SrcB(SrcBE), .Flags(FlagsE));
    alu alu(SrcAE, SrcBE, ALUControlE, ALUResult_Raw);
    mul #(32) mul(.clk, .reset, .ForwardedSrcAE(SrcAE), .ForwardedSrcBE(SrcBE), .IsMulE(IsMulE), .Funct3E(Funct3E), .ProdE(ProdE), .MulWorking(MulWorking));

    // Select ALU result:
    logic [31:0] ALUOutE;
    always_comb
        if      (IsMulE)   ALUOutE = ProdE;          // MUL/MULH/MULHSU/MULHU
        else if (CSRSrcE)  ALUOutE = SharedDataE;    // CSR
        else               ALUOutE = ALUResult_Raw;  // normal ALU

    // Branch/Jump Target Logic
    adder pcadder(PCE, SharedDataE, BranchTargetE);
    logic [31:1] TargetUpper;
    assign TargetUpper = JalrE ? ALUOutE[31:1] : BranchTargetE[31:1];
    assign PCTargetE = {TargetUpper, 1'b0};

    // Output the final ALUResultE to the rest of the pipeline
    always_comb
        case (ResultSrcE)
            2'b11:   ALUResultE = PCTargetE;  // AUIPC
            2'b10:   ALUResultE = PCPlus4E;   // JAL / JALR
            default: ALUResultE = ALUOutE;    // LW / SW / R-Type / I-Type / CSR / MUL
        endcase

    // Execute stage actual taken logic
    logic base_flag;
    always_comb begin
        case (Funct3E[2:1])
            2'b00: base_flag = FlagsE[0]; // BEQ / BNE
            2'b10: base_flag = FlagsE[1]; // BLT / BGE
            2'b11: base_flag = FlagsE[2]; // BLTU / BGEU
            default: base_flag = 1'b0;
        endcase
    end

    // XOR with base flag for branch taken logic (BEQ vs BNE, BLT vs BGE, BLTU vs BGEU)
    assign BranchTaken = base_flag ^ Funct3E[0];


    logic ActualTakenE;
    assign ActualTakenE = (BranchE & BranchTaken) | JumpE | JalrE;

    // We mispredicted if our prediction doesn't match reality
    assign MispredictE = ActualTakenE ^ PredictTakenE;

    // If we mispredicted, where do we go?
    // If it was actually taken (but we predicted NT), go to target.
    // If it was actually NOT taken (but we predicted T), go to PC+4.
    assign RecoveryPCE = ActualTakenE ? PCTargetE : PCPlus4E;

    logic IsLoadE, IsLoadM, IsLoadW;
    assign IsLoadE = (ResultSrcE == 2'b01);

    flopenrc #(1) IsLoadMReg(clk, reset, FlushM, ~StallM, IsLoadE, IsLoadM);
    flopenrc #(1) IsLoadWReg(clk, reset, FlushW, ~StallW, IsLoadM, IsLoadW);

    // Writeback mux
    assign ResultW = IsLoadW ? ReadDataW : ALUResultW;

endmodule
