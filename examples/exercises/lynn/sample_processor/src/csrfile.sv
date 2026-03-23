// csrfile.sv
// RISC-V CSR Register File
// Supports Zicntr: cycle, cycleh, instret, instreth
// CSRRS: rd = CSR[addr]; CSR[addr] |= rs1

module csrfile(
    input  logic        clk, reset,
    input  logic        CSRWrite,           // asserted for CSRRS
    input  logic [11:0] CSRAdr,             // CSR address from Instr[31:20]
    input  logic [31:0] RS1,                // set bits source (R1 from regfile)
    input  logic        RetiredInstr,       // pulse high each retired instruction
    input  logic [6:0]  Op,                 // from Instr[6:0]
    input  logic [2:0]  Funct3,             // from Instr[14:12]
    input  logic [6:0]  Funct7,           // from Instr[30]
    input  logic        PCSrc,              // for branch taken
    output logic [31:0] CSRReadData        // CSR value to write to rd
);

    // Zicntr CSR addresses
    localparam RDCYCLE    = 12'hC00;
    localparam RDCYCLEH   = 12'hC80;
    localparam RDTIME     = 12'hC01;
    localparam RDTIMEH    = 12'hC81;
    localparam RDINSTRET  = 12'hC02;
    localparam RDINSTRETH = 12'hC82;

    //HPM counters
    //hpm3 = # of add instructions run
    localparam hpmcounter3  = 12'hC03; localparam hpmcounter3h = 12'hC83;

    //hpm4 = # of branches evaluated
    localparam hpmcounter4  = 12'hC04; localparam hpmcounter4h = 12'hC84;

    //hpm5 = # of branches taken
    localparam hpmcounter5  = 12'hC05; localparam hpmcounter5h = 12'hC85;

    localparam hpmcounter6  = 12'hC06; localparam hpmcounter6h  = 12'hC86;
    localparam hpmcounter7  = 12'hC07; localparam hpmcounter7h  = 12'hC87;
    localparam hpmcounter8  = 12'hC08; localparam hpmcounter8h  = 12'hC88;
    localparam hpmcounter9  = 12'hC09; localparam hpmcounter9h  = 12'hC89;
    localparam hpmcounter10 = 12'hC0A; localparam hpmcounter10h = 12'hC8A;
    localparam hpmcounter11 = 12'hC0B; localparam hpmcounter11h = 12'hC8B;


    // Counter registers
    logic [63:0] cycle_count;
    logic [63:0] instret_count;
    logic [63:0] add_count;
    logic [63:0] branch_count;
    logic [63:0] branch_taken_count;
    logic [63:0] load_count, store_count, jump_count;
    logic [63:0] mul_count, shift_count, logical_count;

    // cycle increments every clock, CSRRS can set bits
    always_ff @(posedge clk)
        if (reset)
            cycle_count <= 64'hFFFFFFFFFFFFFFFF;
        else begin
            cycle_count <= cycle_count + 1;
            if (CSRWrite & (RS1 != 32'b0))
                case (CSRAdr)
                    RDCYCLE:  cycle_count[31:0]  <= (cycle_count[31:0]  + 1) | RS1;
                    RDCYCLEH: cycle_count[63:32] <= (cycle_count[63:32]) | RS1;
                    default: ;
                endcase
        end

    // instret increments every retired instruction, CSRRS can set bits
    always_ff @(posedge clk)
        if (reset)
            instret_count <= 64'b0;
        else begin
            if (RetiredInstr) instret_count <= instret_count + 1;
            if (CSRWrite & (RS1 != 32'b0))
                case (CSRAdr)
                    RDINSTRET:  instret_count[31:0]  <= instret_count[31:0]  | RS1;
                    RDINSTRETH: instret_count[63:32] <= instret_count[63:32] | RS1;
                    default: ;
                endcase
        end

    //HPM counters logic
    logic AddInstr, BranchInstr, BranchTaken;
    logic LoadInstr, StoreInstr, JumpInstr, MulInstr, ShiftInstr, LogicalInstr;

    logic RType, IType;
    assign RType = (Op == 7'b0110011);
    assign IType = (Op == 7'b0010011);

    assign AddInstr     = (RType & (Funct3 == 3'b000) & (Funct7 == 7'b0000000)) |
                        (IType & (Funct3 == 3'b000));

    assign MulInstr     = (RType & (Funct7 == 7'b0000001));  // all 4 MUL variants

    assign ShiftInstr   = (RType & (Funct3 == 3'b001) & (Funct7 == 7'b0000000)) | // SLL
                        (RType & (Funct3 == 3'b101) & (Funct7 == 7'b0000000)) | // SRL
                        (RType & (Funct3 == 3'b101) & (Funct7 == 7'b0100000)) | // SRA
                        (IType & (Funct3 == 3'b001) & (Funct7 == 7'b0000000)) | // SLLI
                        (IType & (Funct3 == 3'b101) & (Funct7 == 7'b0000000)) | // SRLI
                        (IType & (Funct3 == 3'b101) & (Funct7 == 7'b0100000));  // SRAI

    assign LogicalInstr = (RType & (Funct3 == 3'b100) & (Funct7 == 7'b0000000)) | // XOR
                        (RType & (Funct3 == 3'b110) & (Funct7 == 7'b0000000)) | // OR
                        (RType & (Funct3 == 3'b111) & (Funct7 == 7'b0000000)) | // AND
                        (IType & (Funct3 == 3'b100)) |                           // XORI
                        (IType & (Funct3 == 3'b110)) |                           // ORI
                        (IType & (Funct3 == 3'b111));                            // ANDI

    assign BranchInstr  = (Op == 7'b1100011);
    assign BranchTaken  = (Op == 7'b1100011) & PCSrc;
    assign LoadInstr    = (Op == 7'b0000011);
    assign StoreInstr   = (Op == 7'b0100011);
    assign JumpInstr    = (Op == 7'b1101111) | (Op == 7'b1100111);

    // HPM counter blocks
    always_ff @(posedge clk)
        if (reset)         add_count <= 64'b0;
        else if (AddInstr) add_count <= add_count + 1;

    always_ff @(posedge clk)
        if (reset)            branch_count <= 64'b0;
        else if (BranchInstr) branch_count <= branch_count + 1;

    always_ff @(posedge clk)
        if (reset)            branch_taken_count <= 64'b0;
        else if (BranchTaken) branch_taken_count <= branch_taken_count + 1;

    always_ff @(posedge clk)
        if (reset)          load_count <= 64'b0;
        else if (LoadInstr) load_count <= load_count + 1;

    always_ff @(posedge clk)
        if (reset)           store_count <= 64'b0;
        else if (StoreInstr) store_count <= store_count + 1;

    always_ff @(posedge clk)
        if (reset)          jump_count <= 64'b0;
        else if (JumpInstr) jump_count <= jump_count + 1;

    always_ff @(posedge clk)
        if (reset)         mul_count <= 64'b0;
        else if (MulInstr) mul_count <= mul_count + 1;

    always_ff @(posedge clk)
        if (reset)           shift_count <= 64'b0;
        else if (ShiftInstr) shift_count <= shift_count + 1;

    always_ff @(posedge clk)
        if (reset)             logical_count <= 64'b0;
        else if (LogicalInstr) logical_count <= logical_count + 1;

    // -------------------------------------------------------------------------
    // Combinational read
    // -------------------------------------------------------------------------
    always_comb
        case (CSRAdr)
            RDCYCLE:       CSRReadData = cycle_count[31:0];
            RDCYCLEH:      CSRReadData = cycle_count[63:32];
            RDTIME:        CSRReadData = cycle_count[31:0];
            RDTIMEH:       CSRReadData = cycle_count[63:32];
            RDINSTRET:     CSRReadData = instret_count[31:0];
            RDINSTRETH:    CSRReadData = instret_count[63:32];
            hpmcounter3:   CSRReadData = add_count[31:0];
            hpmcounter3h:  CSRReadData = add_count[63:32];
            hpmcounter4:   CSRReadData = branch_count[31:0];
            hpmcounter4h:  CSRReadData = branch_count[63:32];
            hpmcounter5:   CSRReadData = branch_taken_count[31:0];
            hpmcounter5h:  CSRReadData = branch_taken_count[63:32];
            hpmcounter6:   CSRReadData = load_count[31:0];
            hpmcounter6h:  CSRReadData = load_count[63:32];
            hpmcounter7:   CSRReadData = store_count[31:0];
            hpmcounter7h:  CSRReadData = store_count[63:32];
            hpmcounter8:   CSRReadData = jump_count[31:0];
            hpmcounter8h:  CSRReadData = jump_count[63:32];
            hpmcounter9:   CSRReadData = mul_count[31:0];
            hpmcounter9h:  CSRReadData = mul_count[63:32];
            hpmcounter10:  CSRReadData = shift_count[31:0];
            hpmcounter10h: CSRReadData = shift_count[63:32];
            hpmcounter11:  CSRReadData = logical_count[31:0];
            hpmcounter11h: CSRReadData = logical_count[63:32];
            default:       CSRReadData = 32'b0;
        endcase

endmodule
