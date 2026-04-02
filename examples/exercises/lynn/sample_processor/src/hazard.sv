// hazard.sv
// RISC-V pipelined processor
// pclark@hmc.edu mconine@hmc.edu 2026


module hazard(
	// Inputs
        input   logic           clk, reset,
        input   logic [4:0]		Rs1D, Rs2D,
		input	logic [4:0]		Rs1E, Rs2E, 
		input	logic [4:0]		RdE, 
		input	logic			PCSrcE, // 1 if branch is taken
		input	logic 			ResultSrcE0, // 1 if lw is in execute stage
		input 	logic [4:0]		RdM,
		input	logic 			RegWriteM,
		input	logic			RegWriteW,
		input 	logic [4:0]		RdW,


		// Outputs
		output	logic	        StallF,
		output	logic			StallD, FlushD
		output	logic			StallE, FlushE
		output	logic [1:0]		ForwardAE, ForwardBE,
        output	logic           StallM, FlushM, 
        output	logic           StallW, FlushW
)

	logic lwStall;
	assign lwStall = ResultSrcE0 & ((Rs1D == RdE) | (Rs2D == RdE)); // stalled due to lw dependency
    
    assign StallF = lwStall;
    assign StallD = lwStall;

    // flush when a branch is taken or a load introduces a bubble
    assign FlushD = PCSrcE;
    assign FlushE = lwStall | PCSrcE;

	// forward to solve data hazards whenever possible
    always_comb begin
        if      (((Rs1E == RdM) & RegWriteM) & (Rs1E != 5'b0)) ForwardAE = 2'b10; // forward from Memory stage
        else if (((Rs1E == RdW) & RegWriteW) & (Rs1E != 5'b0)) ForwardAE = 2'b01; // forward from Writeback stage
        else                                                   ForwardAE = 2'b00; // no forwarding, RD1E goes through
    end

    always_comb begin
        if      (((Rs2E == RdM) & RegWriteM) & (Rs2E != 5'b0)) ForwardBE = 2'b10; // forward from Memory stage
        else if (((Rs2E == RdW) & RegWriteW) & (Rs2E != 5'b0)) ForwardBE = 2'b01; // forward from Writeback stage
        else                                                   ForwardBE = 2'b00; // no forwarding, RS2E goes through
    end


endmodule