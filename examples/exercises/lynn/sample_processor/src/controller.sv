// controller.sv
// RISC-V multi-cycle processor
// Max Conine and Pierce Clark

module controller(
	input logic clk, reset,
	// -- inputs -- 
	// Decode stage control signals
    input  logic [31:0] InstrD,                  // Instruction in Decode stage
	output logic [2:0]  ImmSrcD,                 // Type of immediate extension
    // Execute stage control signals
	input  logic [2:0] 	FlagsE, 			     // Comparison flags ({eq, lt})
	input  logic 		StallE, FlushE,			 // Stall, flush Execute stage
	input  logic		ZeroE,
	output logic [1:0]	ResultSrcE,
	output logic [2:0]  ALUControlE,			 // ALU Control signals from Execute stage
	output logic		ALUSrcE,
	output logic		PCSrcE,					 // 1 for PCTargetE, 0 for PCPlus4
	// Memory stage control signals
	input  logic        StallM, FlushM,          // Stall, flush Memory stage
	output logic        MemEnM,					 // MemEn for loads and stores
	output logic 		RegWriteM,				 // For writing to register
	output logic		MemWriteM,               // Mem write for stores

	// Writeback control signals
	input  logic        StallW, FlushW,          // Stall, flush Writeback stage
	output logic        RegWriteW,
	output logic [1:0]	ResultSrcW,


	// do we need this? output logic        CSRReadM, CSRWriteM, PrivilegedM, // CSR read, write, or privileged instruction
	// input  logic        StallD, FlushD,          // Stall, flush Decode stage. Removed bc don't need to check if instruction is valid

	// -- Outputs --
	
	// old
    output logic       ALUResultSrc,
    output logic       ResultSrc,
    output logic       PCSrc,
    output logic       RegWrite,
    output logic       MemWrite,
    output logic [1:0] ALUSrc,
    output logic [2:0] ImmSrc,
    output logic [4:0] ALUControl,

    output logic       CSRSrc
);

	logic [6:0] OpD;                             // Opcode in Decode stage
	logic [2:0] Funct3D;                         // Funct3 field in Decode stage
	logic [6:0] Funct7D;                         // Funct7 field in Decode stage

	// pipelined control signals
	// decode
  	logic       RegWriteD, MemWriteD, JumpD, BranchD, ALUSrcD;
	logic [1:0]	ResultSrcD;
	logic [2:0] ALUControlD;
	// execute
	logic RegWriteE;

	// memory

	// write

	logic [2:0]  ResultSrcD, ResultSrcM; // Select which result to write back to register file
	
	logic MemWriteD

	// Extract fields
	assign OpD     = InstrD[6:0];
	assign Funct3D = InstrD[14:12];
	assign Funct7D = InstrD[31:25];
	assign Rs1D    = InstrD[19:15];
	assign Rs2D    = InstrD[24:20];
	assign RdD     = InstrD[11:7];

	assign PCSrcE = JumpE | (BranchE & ZeroE);


	flopenrc #(32) RD1EReg(clk, reset, FlushE, ~StallE, {RegWriteD, ResultSrcD, MemWriteD, JumpD, BranchD, ALUControlD, ALUControlD, ALUSrcD}, {RegWriteD, ResultSrcD, MemWriteD, JumpD, BranchD, ALUControlD, ALUControlD, ALUSrcD});

	// old

    logic Branch, Jump,BranchTaken;

    always_comb begin
        // Safe defaults — prevent latches and X-propagation on unknown opcodes
        RegWrite     = 1'b0;
        ImmSrcD       = 3'b000;
        ALUSrc       = 2'b00;
        ALUResultSrc = 1'b0;
        MemWriteD     = 1'b0;
        ResultSrc    = 1'b0;
        Branch       = 1'b0;
        Jump         = 1'b0;
        MemEn        = 1'b0;
        ALUControl   = 5'b00000; // ADD
        BranchTaken = 1'b0;
        CSRSrc = 1'b0;

        case (Op)

            // -----------------------------------------------------------------
            // LW  (Op = 0000011)
            // rd = M[rs1 + imm]
            // -----------------------------------------------------------------
            7'b0000011: begin
                RegWrite     = 1'b1;
                ImmSrcD       = 3'b000;    // I-immediate
                ALUSrc       = 2'b01;    // immediate offset
                ALUResultSrc = 1'b0;
                MemWriteD     = 1'b0;
                ResultSrc    = 1'b1;     // write data from memory to rd
                Branch       = 1'b0;
                Jump         = 1'b0;
                MemEn        = 1'b1;
                CSRSrc       = 1'b0;
                ALUControl   = 5'b00000; // ADD (address = rs1 + imm)
            end

            // -----------------------------------------------------------------
            // SW  (Op = 0100011)
            // M[rs1 + imm] = rs2
            // -----------------------------------------------------------------
            7'b0100011: begin
                RegWrite     = 1'b0;
                ImmSrcD       = 3'b001;    // S-immediate
                ALUSrc       = 2'b01;    // immediate offset
                ALUResultSrc = 1'b0;
                MemWriteD     = 1'b1;
                ResultSrc    = 1'b0;
                Branch       = 1'b0;
                Jump         = 1'b0;
                MemEn        = 1'b1;
                CSRSrc       = 1'b0;
                ALUControl   = 5'b00000; // ADD (address = rs1 + imm)
            end

            // -----------------------------------------------------------------
            // R-TYPE  (Op = 0110011)
            // rd = rs1 <op> rs2
            // -----------------------------------------------------------------

            7'b0110011: begin
                RegWrite     = 1'b1;
                ImmSrcD       = 3'bxxx;    // unused
                ALUSrc       = 2'b00;    // both operands from register file
                ALUResultSrc = 1'b0;
                MemWriteD     = 1'b0;
                ResultSrc    = 1'b0;
                Branch       = 1'b0;
                Jump         = 1'b0;
                MemEn        = 1'b0;
                CSRSrc       = 1'b0;

                if (Funct7[0]) begin
                    // Zmmul
                    case (Funct3)
                        3'b000: ALUControl = 5'b01100; // MUL
                        3'b001: ALUControl = 5'b01101; // MULH
                        3'b010: ALUControl = 5'b01110; // MULHSU
                        3'b011: ALUControl = 5'b01111; // MULHU
                        default: ALUControl = 5'b00000;
                    endcase
                end else begin
                    case (Funct3)
                        3'b000: ALUControl = Funct7[5] ? 5'b00001  // SUB
                                                    : 5'b00000; // ADD
                        3'b001: ALUControl = 5'b00010; // SLL
                        3'b010: ALUControl = 5'b00011; // SLT
                        3'b011: ALUControl = 5'b00100; // SLTU
                        3'b100: ALUControl = 5'b00101; // XOR
                        3'b101: ALUControl = Funct7[5] ? 5'b00111 : 5'b00110; // SRA or SRL
                        3'b110: ALUControl = 5'b01000; // OR
                        3'b111: ALUControl = 5'b01001; // AND
                        default: ALUControl = 5'b00000;
                    endcase
                end
            end

            // -----------------------------------------------------------------
            // I-TYPE ALU  (Op = 0010011)
            // rd = rs1 <op> imm
            // -----------------------------------------------------------------
            7'b0010011: begin
                RegWrite     = 1'b1;
                ImmSrcD       = 3'b000;    // I-immediate
                ALUSrc       = 2'b01;    // second operand = immediate
                ALUResultSrc = 1'b0;
                MemWriteD     = 1'b0;
                ResultSrc    = 1'b0;
                Branch       = 1'b0;
                Jump         = 1'b0;
                MemEn        = 1'b0;
                CSRSrc       = 1'b0;

                case (Funct3)
                    3'b000: ALUControl = 5'b00000; // ADDI
                    3'b001: ALUControl = 5'b00010; // SLLI
                    3'b010: ALUControl = 5'b00011; // SLTI
                    3'b011: ALUControl = 5'b00100; // SLTUI
                    3'b100: ALUControl = 5'b00101; // XOR
                    3'b101: ALUControl = Funct7[5] ? 5'b00111 : 5'b00110; // SRAI or SRLI
                    3'b110: ALUControl = 5'b01000; // ORI
                    3'b111: ALUControl = 5'b01001; // ANDI
                    default: ALUControl = 5'b00000;
                endcase
            end

            // -----------------------------------------------------------------
            // LUI  (Op = 0110111)
            // rd = {imm, 12'b0}  — upper immediate, rs1 unused
            // -----------------------------------------------------------------
            7'b0110111: begin
                RegWrite     = 1'b1;
                ImmSrcD       = 3'b100;    // U-immediate
                ALUSrc       = 2'b01;    // pass immediate as SrcB; SrcA unused
                ALUResultSrc = 1'b0;
                MemWriteD     = 1'b0;
                ResultSrc    = 1'b0;
                Branch       = 1'b0;
                Jump         = 1'b0;
                MemEn        = 1'b0;
                CSRSrc       = 1'b0;
                ALUControl   = 5'b01010; // PASS-B (rd = SrcB = upper immediate)
            end

            // -----------------------------------------------------------------
            // BRANCH  (Op = 1100011)
            // BEQ: if (rs1 == rs2) PC = PC + imm  — Funct3 = 000
            // BNE: if (rs1 != rs2) PC = PC + imm  — Funct3 = 001
            // -----------------------------------------------------------------
            7'b1100011: begin
                RegWrite     = 1'b0;
                ImmSrcD       = 3'b010;    // B-immediate
                ALUSrc       = 2'b11;    // both operands from register file
                ALUResultSrc = 1'b0;
                MemWriteD     = 1'b0;
                ResultSrc    = 1'b0;
                Branch       = 1'b1;
                Jump         = 1'b0;
                MemEn        = 1'b0;
                CSRSrc       = 1'b0;
                ALUControl   = 5'b00000; // ADD (sets zero flag for Eq)

                case (Funct3)
                    3'b000: BranchTaken = FlagsE[0];   // BEQ  — equal
                    3'b001: BranchTaken = ~FlagsE[0];  // BNE  — not equal
                    3'b100: BranchTaken = FlagsE[1];   // BLT  — signed less than
                    3'b101: BranchTaken = ~FlagsE[1];  // BGE  — signed greater or equal (not less than)
                    3'b110: BranchTaken = FlagsE[2];   // BLTU — unsigned less than
                    3'b111: BranchTaken = ~FlagsE[2];  // BGEU — unsigned greater or equal (not less than)
                    default: BranchTaken = 1'b0;
                endcase
            end

            // -----------------------------------------------------------------
            // JAL  (Op = 1101111)
            // rd = PC+4 ; PC = PC + imm
            // -----------------------------------------------------------------
            7'b1101111: begin
                RegWrite     = 1'b1;
                ImmSrcD       = 3'b011;    // J-immediate
                ALUSrc       = 2'b11;    // PC + imm (computed in separate adder)
                ALUResultSrc = 1'b1;     // write PC+4 to rd
                MemWriteD     = 1'b0;
                ResultSrc    = 1'b0;
                Branch       = 1'b0;
                Jump         = 1'b1;
                MemEn        = 1'b0;
                CSRSrc       = 1'b0;
                ALUControl   = 5'b00000; // ADD (jump target)
            end

            // -----------------------------------------------------------------
            // JALR  (Op = 1100111)
            // rd = PC+4 ; PC = (rs1 + imm) & ~1
            // -----------------------------------------------------------------
            7'b1100111: begin
                RegWrite     = 1'b1;
                ImmSrcD       = 3'b000;   // I-immediate
                ALUSrc       = 2'b01;    // SrcA = rs1, SrcB = immediate
                ALUResultSrc = 1'b1;     // write PC+4 to rd
                MemWriteD     = 1'b0;
                ResultSrc    = 1'b0;
                Branch       = 1'b0;
                Jump         = 1'b1;
                MemEn        = 1'b0;
                CSRSrc       = 1'b0;
                ALUControl = 5'b01011; // ADD + clear LSB for JALR
            end

            // -----------------------------------------------------------------
            // AUIPC  (Op = 0010111)
            // rd = PC + {imm, 12'b0}
            // -----------------------------------------------------------------
            7'b0010111: begin
                RegWrite     = 1'b1;
                ImmSrcD       = 3'b100;   // U-immediate
                ALUSrc       = 2'b11;    // SrcA = PC, SrcB = immediate
                ALUResultSrc = 1'b0;
                MemWriteD     = 1'b0;
                ResultSrc    = 1'b0;
                Branch       = 1'b0;
                Jump         = 1'b0;
                MemEn        = 1'b0;
                CSRSrc       = 1'b0;
                ALUControl   = 5'b00000; // ADD (PC + imm)
            end

            // -----------------------------------------------------------------
            // CSRRS  (Op = 1110011)
            // rd = CSR[addr]; CSR[addr] |= rs1
            // -----------------------------------------------------------------
            7'b1110011: begin
                RegWrite     = 1'b1;    // write CSR value to rd
                ImmSrcD       = 3'b000;  // unused
                ALUSrc       = 2'b00;
                ALUResultSrc = 1'b0;
                MemWriteD     = 1'b0;
                ResultSrc    = 1'b0;
                Branch       = 1'b0;
                Jump         = 1'b0;
                MemEn        = 1'b0;
                ALUControl   = 5'b00000;
                CSRSrc       = 1'b1;    // select CSR result into result mux
            end

            // Default / unimplemented
            default: begin
`ifdef DEBUG
                if (insn_debug !== 'x) begin
                    $display("Instruction not implemented: %h", insn_debug);
                    $finish(-1);
                end
`endif
                // all signals hold the safe defaults assigned at the top
            end
        endcase
    end

    // Output assignments
    assign PCSrc = (Branch & BranchTaken) | Jump;

endmodule
