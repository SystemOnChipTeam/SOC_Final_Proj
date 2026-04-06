// csrfile.sv
// RISC-V CSR Register File
// Supports Zicntr compliance and Custom Telemetry

// TODO parameterize this to optimize area for coremark test.
module csrfile(
    input  logic        clk, reset,
    input  logic        CSRWrite,           // (Unused - Counters are Read-Only)
    input  logic [11:0] CSRAdr,             // CSR address from Instr[31:20]
    input  logic [31:0] RS1,                // (Unused - Counters are Read-Only)
    input  logic        RetiredInstr,       // pulse high each retired instruction
    input  logic [6:0]  Op,                 // from Instr[6:0]
    input  logic [2:0]  Funct3,             // from Instr[14:12]
    input  logic [6:0]  Funct7,             // from Instr[31:25]
    input  logic        PCSrc,              // for branch taken
    output logic [31:0] CSRReadData         // CSR value to write to rd
);

    // Zicntr CSR addresses (Standard Read-Only)
    localparam RDCYCLE    = 12'hC00;
    localparam RDCYCLEH   = 12'hC80;
    localparam RDTIME     = 12'hC01;
    localparam RDTIMEH    = 12'hC81;
    localparam RDINSTRET  = 12'hC02;
    localparam RDINSTRETH = 12'hC82;

    // Custom Telemetry Counters
    // Mapped to RISC-V Custom Read-Only Space (0xFC0 - 0xFCB)
    localparam custom_add    = 12'hFC0; localparam custom_addh    = 12'hFC1;
    localparam custom_branch = 12'hFC2; localparam custom_branchh = 12'hFC3;
    localparam custom_btaken = 12'hFC4; localparam custom_btakenh = 12'hFC5;
    localparam custom_load   = 12'hFC6; localparam custom_loadh   = 12'hFC7;
    localparam custom_store  = 12'hFC8; localparam custom_storeh  = 12'hFC9;
    localparam custom_jump   = 12'hFCA; localparam custom_jumph   = 12'hFCB;
    localparam custom_mul    = 12'hFCC; localparam custom_mulh    = 12'hFCD;
    localparam custom_shift  = 12'hFCE; localparam custom_shifth  = 12'hFCF;
    localparam custom_logic  = 12'hFD0; localparam custom_logich  = 12'hFD1;

    // Counter registers
    logic [63:0] cycle_count;
    logic [63:0] instret_count;
    logic [63:0] add_count;
    logic [63:0] branch_count;
    logic [63:0] branch_taken_count;
    logic [63:0] load_count, store_count, jump_count;
    logic [63:0] mul_count, shift_count, logical_count;

    // Zicntr
    always_ff @(posedge clk) begin
        if (reset) begin
            cycle_count   <= 64'b0;
            instret_count <= 64'b0;
        end else begin
            cycle_count <= cycle_count + 1;
            if (RetiredInstr) instret_count <= instret_count + 1;
        end
    end

    logic AddInstr, BranchInstr, BranchTaken;
    logic LoadInstr, StoreInstr, JumpInstr, MulInstr, ShiftInstr, LogicalInstr;

    logic RType, IType;
    assign RType = (Op == 7'b0110011);
    assign IType = (Op == 7'b0010011);

    assign AddInstr     = (RType & (Funct3 == 3'b000) & (Funct7 == 7'b0000000)) |
                          (IType & (Funct3 == 3'b000));
    assign MulInstr     = (RType & (Funct7 == 7'b0000001));
    assign ShiftInstr   = (RType & (Funct3 == 3'b001) & (Funct7 == 7'b0000000)) |
                          (RType & (Funct3 == 3'b101) & (Funct7 == 7'b0000000)) |
                          (RType & (Funct3 == 3'b101) & (Funct7 == 7'b0100000)) |
                          (IType & (Funct3 == 3'b001) & (Funct7 == 7'b0000000)) |
                          (IType & (Funct3 == 3'b101) & (Funct7 == 7'b0000000)) |
                          (IType & (Funct3 == 3'b101) & (Funct7 == 7'b0100000));
    assign LogicalInstr = (RType & (Funct3 == 3'b100) & (Funct7 == 7'b0000000)) |
                          (RType & (Funct3 == 3'b110) & (Funct7 == 7'b0000000)) |
                          (RType & (Funct3 == 3'b111) & (Funct7 == 7'b0000000)) |
                          (IType & (Funct3 == 3'b100)) |
                          (IType & (Funct3 == 3'b110)) |
                          (IType & (Funct3 == 3'b111));
    assign BranchInstr  = (Op == 7'b1100011);
    assign BranchTaken  = (Op == 7'b1100011) & PCSrc;
    assign LoadInstr    = (Op == 7'b0000011);
    assign StoreInstr   = (Op == 7'b0100011);
    assign JumpInstr    = (Op == 7'b1101111) | (Op == 7'b1100111);

    // HPM Counter Blocks
    always_ff @(posedge clk) begin
        if (reset) begin
            add_count          <= 64'b0;
            branch_count       <= 64'b0;
            branch_taken_count <= 64'b0;
            load_count         <= 64'b0;
            store_count        <= 64'b0;
            jump_count         <= 64'b0;
            mul_count          <= 64'b0;
            shift_count        <= 64'b0;
            logical_count      <= 64'b0;
        end else if (RetiredInstr) begin
            if (AddInstr)     add_count          <= add_count + 1;
            if (BranchInstr)  branch_count       <= branch_count + 1;
            if (BranchTaken)  branch_taken_count <= branch_taken_count + 1;
            if (LoadInstr)    load_count         <= load_count + 1;
            if (StoreInstr)   store_count        <= store_count + 1;
            if (JumpInstr)    jump_count         <= jump_count + 1;
            if (MulInstr)     mul_count          <= mul_count + 1;
            if (ShiftInstr)   shift_count        <= shift_count + 1;
            if (LogicalInstr) logical_count      <= logical_count + 1;
        end
    end

    always_comb begin
        case (CSRAdr)
            // Standard Zicntr (Compliance tests will read these)
            RDCYCLE:       CSRReadData = cycle_count[31:0];
            RDCYCLEH:      CSRReadData = cycle_count[63:32];
            RDTIME:        CSRReadData = cycle_count[31:0];
            RDTIMEH:       CSRReadData = cycle_count[63:32];
            RDINSTRET:     CSRReadData = instret_count[31:0];
            RDINSTRETH:    CSRReadData = instret_count[63:32];

            // Custom Telemetry Counters
            custom_add:    CSRReadData = add_count[31:0];
            custom_addh:   CSRReadData = add_count[63:32];
            custom_branch: CSRReadData = branch_count[31:0];
            custom_branchh:CSRReadData = branch_count[63:32];
            custom_btaken: CSRReadData = branch_taken_count[31:0];
            custom_btakenh:CSRReadData = branch_taken_count[63:32];
            custom_load:   CSRReadData = load_count[31:0];
            custom_loadh:  CSRReadData = load_count[63:32];
            custom_store:  CSRReadData = store_count[31:0];
            custom_storeh: CSRReadData = store_count[63:32];
            custom_jump:   CSRReadData = jump_count[31:0];
            custom_jumph:  CSRReadData = jump_count[63:32];
            custom_mul:    CSRReadData = mul_count[31:0];
            custom_mulh:   CSRReadData = mul_count[63:32];
            custom_shift:  CSRReadData = shift_count[31:0];
            custom_shifth: CSRReadData = shift_count[63:32];
            custom_logic:  CSRReadData = logical_count[31:0];
            custom_logich: CSRReadData = logical_count[63:32];

            default:       CSRReadData = 32'b0;
        endcase
    end

endmodule
