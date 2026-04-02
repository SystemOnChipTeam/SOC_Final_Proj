// ifu.sv
// RISC-V pipelined processor
// pclark@hmc.edu mconine@hmc.edu 2026

module ifu(
        // Inputs
        input   logic           clk, reset,
        input   logic           PCSrcE,    // Program Counter source, 1 if branch is taken
        input   logic [31:0]    PCTargetE, // Target address from Execute stage for branch/jump instructions

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

    // PC mux: Choose between sequential PC+4 or a branch/jump target from Execute
    mux2 #(32) pcmux(PCPlus4F, PCTargetE, PCSrcE, PCNext);

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
