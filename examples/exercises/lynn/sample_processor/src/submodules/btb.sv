// btb.sv
// RISC-V pipelined processor
// pclark@hmc.edu mconine@hmc.edu 2026

module btb #(
    parameter INDEX_BITS = 4
)(
    input  logic        clk,
    input  logic        reset,

    // --- Fetch Stage (Read) ---
    input  logic [31:0] PCF,
    output logic [31:0] PredictedTargetF,
    output logic        BTBHitF, // 1 if we have a cached target for this PC

    // --- Execute Stage (Write/Update) ---
    input  logic [31:0] PCE,
    input  logic [31:0] PCTargetE, // The actual branch/jump target calculated in E
    input  logic        UpdateBTBE // 1 to write/update the BTB (usually BranchE | JumpE)
);

    // Calculate tag size based on 32-bit PC, minus index bits, minus 2 byte-offset bits
    localparam TAG_BITS = 32 - 2 - INDEX_BITS;
    localparam NUM_ENTRIES = 1 << INDEX_BITS;

    // Define the BTB entry structure
    typedef struct packed {
        logic                valid;
        logic [TAG_BITS-1:0] tag;
        logic [31:0]         target;
    } btb_entry_t;

    // The BTB memory array
    btb_entry_t btb_ram [0 : NUM_ENTRIES-1];

    // -----------------------------------------
    // Read Logic (Combinational for Fetch)
    // -----------------------------------------
    logic [INDEX_BITS-1:0] index_F;
    logic [TAG_BITS-1:0]   tag_F;

    assign index_F = PCF[INDEX_BITS+1 : 2];
    assign tag_F   = PCF[31 : INDEX_BITS+2];

    // We have a hit if the entry is valid AND the tags match
    assign BTBHitF = btb_ram[index_F].valid & (btb_ram[index_F].tag == tag_F);
    assign PredictedTargetF = btb_ram[index_F].target;

    // -----------------------------------------
    // Write Logic (Sequential for Execute)
    // -----------------------------------------
    logic [INDEX_BITS-1:0] index_E;
    logic [TAG_BITS-1:0]   tag_E;

    assign index_E = PCE[INDEX_BITS+1 : 2];
    assign tag_E   = PCE[31 : INDEX_BITS+2];

    always_ff @(posedge clk) begin
        if (reset) begin
            // Invalidate all entries on reset
            for (int i = 0; i < NUM_ENTRIES; i++) begin
                btb_ram[i].valid <= 1'b0;
                btb_ram[i].tag   <= '0;
                btb_ram[i].target<= '0;
            end
        end else if (UpdateBTBE) begin
            // Write the new target and tag into the BTB
            btb_ram[index_E].valid  <= 1'b1;
            btb_ram[index_E].tag    <= tag_E;
            btb_ram[index_E].target <= PCTargetE;
        end
    end

endmodule
