// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020 kacassidy@hmc.edu 2025

module ifu(
        input   logic           clk, reset,
        input   logic           PCSrcE,
        input   logic [31:0]    PCTargetE,
        //stalls
        input   logic           StallF, StallD, FlushD,

        output  logic [31:0]    InstrD, PCD, PCPlus4D,

        //Memory interface   
        output  logic           PCF
        input   logic           InstrF           
    );

    logic   [31:0]  PCW, PCF, PCPlus4F, InstrF;
    
    mux2 #(32) pcmux(PCPlus4F, PCTargetE, PCSrcE, PCW);

    // Pipeline Register F-Stage
    flopen PCFReg(clk, ~StallF, PCW, PCF);

    adder PCadd4f(PCF, 32'd4, PCPlus4F);
    
    // Pipeline Register D-Stage
    flopenrc DReg(clk, reset, FlushD, ~StallD, 
	{InstrF, PCF, PCPlus4F},
	{InstrD, PCD, PCPlus4D});

endmodule

