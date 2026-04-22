// two_bit_predictor.sv
// RISC-V pipelined processor
// pclark@hmc.edu mconine@hmc.edu 2026

module two_bit_predictor #(parameter INDEX_BITS = 4)(
    input  logic        clk,
    input  logic        reset,

    // --- Fetch Stage (Prediction) ---
    input  logic [31:0] PCF,           // Current PC in Fetch
    output logic        PredictTakenF, // 1 if predicted Taken, 0 if Not Taken

    // --- Execute Stage (Update) ---
    input  logic [31:0] PCE,           // PC of the instruction in Execute
    input  logic        BranchE,       // 1 if instruction in E is a branch
    input  logic        ActualTakenE   // 1 if branch was ACTUALLY taken
);

    // Branch History Table (BHT): Array of 2-bit counters
    logic [1:0] bht [0 : (1<<INDEX_BITS)-1];

    // Read logic (Combinational for Fetch)
    logic [INDEX_BITS-1:0] index_F;
    assign index_F = PCF[INDEX_BITS+1 : 2]; // Shift by 2 for word-aligned PC

    // The MSB of the 2-bit counter determines the prediction (1X = Taken, 0X = Not Taken)
    assign PredictTakenF = bht[index_F][1];

    // Update logic (Sequential for Execute)
    logic [INDEX_BITS-1:0] index_E;
    assign index_E = PCE[INDEX_BITS+1 : 2];

    always_ff @(posedge clk) begin
        if (reset) begin
            // Initialize all entries to Weakly Not Taken (01)
            for (int i = 0; i < (1<<INDEX_BITS); i++) begin
                bht[i] <= 2'b01;
            end
        end else if (BranchE) begin
            // 2-Bit Saturating Counter State Machine
            case (bht[index_E])
                2'b00: bht[index_E] <= ActualTakenE ? 2'b01 : 2'b00; // Strong NT -> Weak NT or Strong NT
                2'b01: bht[index_E] <= ActualTakenE ? 2'b10 : 2'b00; // Weak NT   -> Weak T  or Strong NT
                2'b10: bht[index_E] <= ActualTakenE ? 2'b11 : 2'b01; // Weak T    -> Strong T or Weak NT
                2'b11: bht[index_E] <= ActualTakenE ? 2'b11 : 2'b10; // Strong T  -> Strong T or Weak T
            endcase
        end
    end

endmodule
