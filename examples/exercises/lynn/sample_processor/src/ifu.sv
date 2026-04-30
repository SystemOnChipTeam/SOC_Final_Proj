// ifu.sv
// RISC-V pipelined processor
// Max Conine and Pierce Clark
// pclark@hmc.edu mconine@hmc.edu 2026

module ifu(
        // Inputs
        input   logic           clk, reset,

        // Branch Prediction Interface
        input   logic           PredictTakenD,
        input   logic [31:0]    PredictedTargetD,
        input   logic           MispredictE,
        input   logic [31:0]    RecoveryPCE,

        // Stalls
        input   logic           StallF,    // stall the Fetch stage
        input   logic           StallD,    // stall the Decode stage
        input   logic           FlushD,    // flush the Decode stage

        // Outputs
        output  logic [31:0]    InstrD,    // Instruction in Decode stage
        output  logic [31:0]    PCD,       // Program Counter in Decode stage
        output  logic [31:0]    PCPlus4D,  // PC+4 in Decode stage (for JAL)

        // Memory interface
        output  logic [31:0]    PCF,       // Program Counter in Fetch stage
        input   logic [31:0]    InstrF     // Instruction from memory in Fetch stage
    );

    logic   [31:0]  PCNext, PCPlus4F; // Next PC value and PC+4 in Fetch stage
    logic   [31:0]  entry_addr; // Address to jump to on reset, set by plusarg

    initial begin
        // default
        entry_addr = '0;

        // override if provided
        void'($value$plusargs("ENTRY_ADDR=%h", entry_addr));

        $display("[TB] ENTRY_ADDR = 0x%h", entry_addr);
    end

    // PC Priority Mux:
    // 1. If Execute mispredicted, recover immediately.
    // 2. Else if Decode predicts taken (backwards branch or JAL), take it.
    // 3. Else proceed sequentially.
    always_comb begin
        if (MispredictE)        PCNext = RecoveryPCE;
        else if (PredictTakenD) PCNext = PredictedTargetD;
        else                    PCNext = PCPlus4F;
    end

    // PC Register with Reset to entry_addr and Enable (StallF)
    always_ff @(posedge clk) begin
        if (reset)          PCF <= entry_addr;
        else if (~StallF)   PCF <= PCNext;
    end

    // PC+4 adder
    adder PCadd4f(PCF, 32'd4, PCPlus4F);

    // Pipeline Register D-Stage
    flopenrc #(32) InstrDReg  (clk, reset, FlushD, ~StallD, InstrF,    InstrD);
    flopenrc #(32) PCDReg     (clk, reset, FlushD, ~StallD, PCF,       PCD);
    flopenrc #(32) PCPlus4DReg(clk, reset, FlushD, ~StallD, PCPlus4F,  PCPlus4D);

endmodule
