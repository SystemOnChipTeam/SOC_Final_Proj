// ifu.sv
// RISC-V pipelined processor
// pclark@hmc.edu mconine@hmc.edu 2026

module ifu(
        // Inputs
        input   logic           clk, reset,
        input   logic           PCSrcE,
        input   logic [31:0]    PCTargetE,
        
        // Stalls
        input   logic           StallF, StallD, FlushD,

        // Outputs
        output  logic [31:0]    InstrD, PCD, PCPlus4D,

        // Memory interface   
        output  logic [31:0]    PCF,
        input   logic [31:0]    InstrF       
    );

    logic   [31:0]  PCNext, PCPlus4F;
    
    // PC mux
    mux2 #(32) pcmux(PCPlus4F, PCTargetE, PCSrcE, PCNext);

    // Pipeline Register F-Stage
    flopen #(32) PCFReg(clk, ~StallF, PCNext, PCF);

    // PC+4 adder
    adder PCadd4f(PCF, 32'd4, PCPlus4F);
    
    // Pipeline Register D-Stage
    flopenrc #(32) InstrDReg  (clk, reset, FlushD, ~StallD, InstrF,    InstrD);
    flopenrc #(32) PCDReg     (clk, reset, FlushD, ~StallD, PCF,       PCD);
    flopenrc #(32) PCPlus4DReg(clk, reset, FlushD, ~StallD, PCPlus4F,  PCPlus4D);

endmodule

