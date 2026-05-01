// hazard.sv
// RISC-V pipelined processor
// Max Conine and Pierce Clark
// pclark@hmc.edu mconine@hmc.edu 2026

module hazard (
    // Decode Stage Inputs
    input  logic [4:0]  Rs1D, Rs2D,           // Source registers
    input  logic        PredictTakenD,        // Branch predicted taken in Decode

    // Execute Stage Inputs
    input  logic [4:0]  Rs1E, Rs2E,           // Source registers
    input  logic [4:0]  RdE,                  // Destination register
    input  logic        MispredictE,          // Branch mispredicted in Execute
    input  logic        ResultSrcE0,          // Load instruction flag
    input  logic        MulBusy,              // Multi-cycle multiply active flag

    // Memory Stage Inputs
    input  logic [4:0]  RdM,                  // Destination register
    input  logic        RegWriteM,            // Register write enable

    // Writeback Stage Inputs
    input  logic [4:0]  RdW,                  // Destination register
    input  logic        RegWriteW,            // Register write enable

    // Forwarding Controls
    output logic [1:0]  ForwardAE, ForwardBE, // ALU operand mux selects

    // Pipeline Flow Controls
    output logic        StallF,               // Fetch stall
    output logic        StallD, FlushD,       // Decode stall/flush
    output logic        StallE, FlushE,       // Execute stall/flush
    output logic        StallM, FlushM,       // Memory stall/flush
    output logic        StallW, FlushW        // Writeback stall/flush
);

    logic lwStall;
    assign lwStall = ResultSrcE0 & ((Rs1D == RdE) | (Rs2D == RdE)); //& (RdE != 5'b0)

    assign StallF  = lwStall | MulBusy;
    assign StallD  = lwStall | MulBusy;

    // Flush Decode if we mispredict in execute OR if we predict taken in decode
    assign FlushD  = MispredictE | PredictTakenD;
    // Flush Execute if there's a load stall OR if we mispredict in execute
    assign FlushE  = lwStall | MispredictE;

    // forward to solve data hazards whenever possible
    always_comb begin
        if (((Rs1E == RdM) & RegWriteM) & (|Rs1E)) ForwardAE = 2'b10;
        else if (((Rs1E == RdW) & RegWriteW) & (|Rs1E)) ForwardAE = 2'b01;
        else ForwardAE = 2'b00;
    end

    always_comb begin
        if (((Rs2E == RdM) & RegWriteM) & (|Rs2E)) ForwardBE = 2'b10;
        else if (((Rs2E == RdW) & RegWriteW) & (|Rs2E)) ForwardBE = 2'b01;
        else ForwardBE = 2'b00;
    end

    // tie off unused pipeline control signals
    assign StallE = MulBusy;
    assign StallM = MulBusy;
    assign FlushM = 1'b0;
    assign StallW = MulBusy;
    assign FlushW = 1'b0;

endmodule
