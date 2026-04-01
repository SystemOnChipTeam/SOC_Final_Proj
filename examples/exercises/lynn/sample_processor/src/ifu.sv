// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020 kacassidy@hmc.edu 2025

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
        output  logic           PCF,
        input   logic           InstrF,        
    );

    logic   [31:0]  PCNext, PCF, PCPlus4F, InstrF;
    
    // TODO: make sure this mux is in the right order
    mux2 #(32) pcmux(PCPlus4F, PCTargetE, PCSrcE, PCNext);

    // Pipeline Register F-Stage
    flopen PCFReg(clk, ~StallF, PCNext, PCF);

    adder PCadd4f(PCF, 32'd4, PCPlus4F);
    
    // Pipeline Register D-Stage
    flopenrc #(32) RD1EReg(clk, reset, FlushD, ~StallD, InstrF, InstrD);
    flopenrc #(32) RD1EReg(clk, reset, FlushD, ~StallD, PCF, PCD);
    flopenrc #(32) RD1EReg(clk, reset, FlushD, ~StallD, PCPlus4F, PCPlus4D);

endmodule

