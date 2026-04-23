// btb.sv
// RISC-V pipelined processor
// Optimized for Area: Partial Tags, PC-Relative Offsets, and Implicit Alignment
// pclark@hmc.edu mconine@hmc.edu 2026

module btb #(
    parameter INDEX_BITS = 3,
    parameter TAG_BITS = 10,       // Optimization 1: Partial Tag (compressed)
    parameter OFFSET_BITS = 14     // Optimization 2 & 3: Stored offset bits (represents a 16-bit reach)
)(
    input  logic        clk,
    input  logic        reset,

    // --- Fetch Stage (Read) ---
    input  logic [31:0] PCF,
    output logic [31:0] PredictedTargetF,
    output logic        BTBHitF,

    // --- Memory Stage (Write/Update) ---
    input  logic [31:0] PCM,
    input  logic [31:0] PCTargetM,
    input  logic        UpdateBTBM
);

    localparam NUM_ENTRIES = 1 << INDEX_BITS;

    // Define the BTB entry structure
    typedef struct packed {
        logic                   valid;
        logic [TAG_BITS-1:0]    tag;
        logic [OFFSET_BITS-1:0] offset; // Stores bits [OFFSET_BITS+1 : 2] of the branch distance
    } btb_entry_t;

    // The BTB memory array
    btb_entry_t btb_ram [0 : NUM_ENTRIES-1];

    // -----------------------------------------
    // Read Logic (Combinational for Fetch)
    // -----------------------------------------
    logic [INDEX_BITS-1:0] index_F;
    logic [TAG_BITS-1:0]   tag_F;
    logic [31:0]           sign_ext_offset_F;

    // Extract the index and the compressed tag from the PC
    assign index_F = PCF[INDEX_BITS+1 : 2];
    assign tag_F   = PCF[INDEX_BITS+2 + TAG_BITS - 1 : INDEX_BITS+2];

    // We have a hit if the entry is valid AND the partial tags match
    assign BTBHitF = btb_ram[index_F].valid & (btb_ram[index_F].tag == tag_F);

    // Reconstruct the target: Sign-extend the stored offset, pad the bottom 2 bits with 0s, and add to PCF
    assign sign_ext_offset_F = { {(32 - OFFSET_BITS - 2){btb_ram[index_F].offset[OFFSET_BITS-1]}},
                                 btb_ram[index_F].offset,
                                 2'b00 };

    assign PredictedTargetF = PCF + sign_ext_offset_F;

    // -----------------------------------------
    // Write Logic (Sequential for Memory)
    // -----------------------------------------
    logic [INDEX_BITS-1:0] index_M;
    logic [TAG_BITS-1:0]   tag_M;
    logic [31:0]           full_offset_M;

    // Extract the index and the compressed tag from the executing PC
    assign index_M = PCM[INDEX_BITS+1 : 2];
    assign tag_M   = PCM[INDEX_BITS+2 + TAG_BITS - 1 : INDEX_BITS+2];

    // Calculate the absolute distance between the jump target and the current instruction
    assign full_offset_M = PCTargetM - PCM;

    always_ff @(posedge clk) begin
        if (reset) begin
            // Invalidate all entries on reset
            for (int i = 0; i < NUM_ENTRIES; i++) begin
                btb_ram[i].valid  <= 1'b0;
                btb_ram[i].tag    <= '0;
                btb_ram[i].offset <= '0;
            end
        end else if (UpdateBTBM) begin
            // Write the new offset and partial tag into the BTB
            btb_ram[index_M].valid  <= 1'b1;
            btb_ram[index_M].tag    <= tag_M;
            // Chop off the bottom 2 bits (always 00) and store the next OFFSET_BITS
            btb_ram[index_M].offset <= full_offset_M[OFFSET_BITS+1 : 2];
        end
    end

endmodule
