// controller.sv
// RISC-V multi-cycle processor
// Max Conine and Pierce Clark
// pclark@hmc.edu mconine@hmc.edu 2026

module controller(
    input logic clk, reset,
    // -- inputs --
    input  logic [31:0] InstrD,                    // Instruction in Decode stage
    // -- outputs --
    output logic        MemEnD, RegWriteD,         // MemEnD for load/store, RegWriteD for register file write enable
    output logic [1:0]  ResultSrcD,                // Selects value to write to register file: 00 = ALU result, 01 = ReadData, 10 = PC+4, 11 = PCTarget (for AUIPC)
    output logic        MemWriteD, JumpD, BranchD, // control signals for memory write, jump, and branch instructions
    output logic [3:0]  ALUControlD,               // ALU control signals
    output logic        ALUSrcD,                   // 1 chooses ImmExt, O chooses WriteData
    output logic [2:0]  ImmSrcD,                   // Type of immediate extension
    output logic        CSRSrcD,                   // 1 selects CSR result for writing to rd, 0 selects ALU result
    output logic        IsMulD                     // whether the instruction in decode stage is a multiply instruction
);

    logic [6:0] OpD;                             // Opcode in Decode stage
    logic [2:0] Funct3D;                         // Funct3 field in Decode stage
    logic [6:0] Funct7D;                         // Funct7 field in Decode stage

    // extract fields
    assign OpD     = InstrD[6:0];
    assign Funct3D = InstrD[14:12];
    assign Funct7D = InstrD[31:25];

    always_comb begin
        // Safe default values for control signals
        RegWriteD      = 1'b0;
        ImmSrcD       = 3'b000;
        ALUSrcD       = 1'b0;
        ResultSrcD    = 2'b00;
        MemWriteD     = 1'b0;
        BranchD       = 1'b0;
        JumpD         = 1'b0;
        MemEnD        = 1'b0;
        ALUControlD   = 4'b0000; // ADD
        CSRSrcD = 1'b0;
        IsMulD = 1'b0;

        case (OpD)
            // LW  (Op = 0000011)
            // rd = M[rs1 + imm]
            7'b0000011: begin
                RegWriteD     = 1'b1;
                ImmSrcD      = 3'b000;    // I-immediate
                ALUSrcD       = 1'b1;    // immediate offset
                ResultSrcD   = 2'b01;    // write data from memory to rd
                MemWriteD    = 1'b0;
                BranchD       = 1'b0;
                JumpD          = 1'b0;
                MemEnD       = 1'b1;
                CSRSrcD       = 1'b0;
                ALUControlD   = 4'b0000; // ADD (address = rs1 + imm)
            end

            // SW  (Op = 0100011)
            // M[rs1 + imm] = rs2
            7'b0100011: begin
                RegWriteD     = 1'b0;
                ImmSrcD       = 3'b001;    // S-immediate
                ALUSrcD       = 1'b1;    // immediate offset
                ResultSrcD = 2'b00;
                MemWriteD     = 1'b1;
                BranchD       = 1'b0;
                JumpD          = 1'b0;
                MemEnD       = 1'b1;
                CSRSrcD       = 1'b0;
                ALUControlD   = 4'b0000; // ADD (address = rs1 + imm)
            end

            // R-TYPE  (Op = 0110011)
            // rd = rs1 <op> rs2
            7'b0110011: begin
                RegWriteD     = 1'b1;
                ImmSrcD       = 3'bxxx;    // unused
                ALUSrcD       = 1'b0;    // both operands from register file
                ResultSrcD = 2'b00;
                MemWriteD     = 1'b0;
                BranchD       = 1'b0;
                JumpD          = 1'b0;
                MemEnD       = 1'b0;
                CSRSrcD       = 1'b0;
                IsMulD = 1'b0;
                if (Funct7D[0]) begin
                    // Zmmul
                    case (Funct3D)
                        3'b000: ALUControlD = 4'b1100; // MUL
                        3'b001: ALUControlD = 4'b1101; // MULH
                        3'b010: ALUControlD = 4'b1110; // MULHSU
                        3'b011: ALUControlD = 4'b1111; // MULHU
                        default: ALUControlD = 4'b0000;
                    endcase
                    IsMulD = (Funct3D <= 3'b011);
                end else begin
                    case (Funct3D)
                        3'b000: ALUControlD = Funct7D[5] ? 4'b0001  // SUB
                                                    : 4'b0000; // ADD
                        3'b001: ALUControlD = 4'b0010; // SLL
                        3'b010: ALUControlD = 4'b0011; // SLT
                        3'b011: ALUControlD = 4'b0100; // SLTU
                        3'b100: ALUControlD = 4'b0101; // XOR
                        3'b101: ALUControlD = Funct7D[5] ? 4'b0111 : 4'b0110; // SRA or SRL
                        3'b110: ALUControlD = 4'b1000; // OR
                        3'b111: ALUControlD = 4'b1001; // AND
                        default: ALUControlD = 4'b0000;
                    endcase
                end
            end

            // I-TYPE ALU  (Op = 0010011)
            // rd = rs1 <op> imm
            7'b0010011: begin
                RegWriteD     = 1'b1;
                ImmSrcD      = 3'b000;    // I-immediate
                ALUSrcD       = 1'b1;    // second operand = immediate
                ResultSrcD   = 2'b00;
                MemWriteD    = 1'b0;
                BranchD       = 1'b0;
                JumpD          = 1'b0;
                MemEnD       = 1'b0;
                CSRSrcD       = 1'b0;

                case (Funct3D)
                    3'b000: ALUControlD = 4'b0000; // ADDI
                    3'b001: ALUControlD = 4'b0010; // SLLI
                    3'b010: ALUControlD = 4'b0011; // SLTI
                    3'b011: ALUControlD = 4'b0100; // SLTUI
                    3'b100: ALUControlD = 4'b0101; // XOR
                    3'b101: ALUControlD = Funct7D[5] ? 4'b0111 : 4'b0110; // SRAI or SRLI
                    3'b110: ALUControlD = 4'b1000; // ORI
                    3'b111: ALUControlD = 4'b1001; // ANDI
                    default: ALUControlD = 4'b0000;
                endcase
            end

            // LUI  (Op = 0110111)
            // rd = {imm, 12'b0}  — upper immediate, rs1 unused
            7'b0110111: begin
                RegWriteD     = 1'b1;
                ImmSrcD      = 3'b100;    // U-immediate
                ALUSrcD       = 1'b1;    // pass immediate as SrcB; SrcA unused
                ResultSrcD   = 2'b00;
                MemWriteD    = 1'b0;
                BranchD       = 1'b0;
                JumpD          = 1'b0;
                MemEnD       = 1'b0;
                CSRSrcD       = 1'b0;
                ALUControlD  = 4'b1010; // PASS-B (rd = SrcB = upper immediate)
            end

            // BRANCH  (Op = 1100011)
            // if (rs1 cond rs2) PC = PC + imm
            7'b1100011: begin
                RegWriteD     = 1'b0;
                ImmSrcD      = 3'b010;    // B-immediate
                ALUSrcD       = 1'b0;    // both operands from regfter file
                ResultSrcD   = 2'b00;
                MemWriteD    = 1'b0;
                BranchD       = 1'b1;
                JumpD          = 1'b0;
                MemEnD       = 1'b0;
                CSRSrcD       = 1'b0;
                ALUControlD   = 4'b0000; // ADD (sets zero flag for Eq)
            end

            // JAL  (Op = 1101111)
            // rd = PC+4 ; PC = PC + imm
            7'b1101111: begin
                RegWriteD     = 1'b1;
                ImmSrcD       = 3'b011;    // J-immediate
                ALUSrcD       = 1'b1;    // PC + imm (computed in separate adder)
                ResultSrcD   = 2'b10;     // write PC+4 to rd
                MemWriteD     = 1'b0;
                BranchD       = 1'b0;
                JumpD          = 1'b1;
                MemEnD       = 1'b0;
                CSRSrcD       = 1'b0;
                ALUControlD   = 4'b0000; // ADD (jump target)
            end

            // JALR  (Op = 1100111)
            // rd = PC+4 ; PC = (rs1 + imm) & ~1
            7'b1100111: begin
                RegWriteD     = 1'b1;
                ImmSrcD       = 3'b000;   // I-immediate
                ALUSrcD       = 1'b1;    // SrcA = rs1, SrcB = immediate
                ResultSrcD   = 2'b10;     // write PC+4 to rd
                MemWriteD     = 1'b0;
                BranchD       = 1'b0;
                JumpD          = 1'b1;
                MemEnD       = 1'b0;
                CSRSrcD       = 1'b0;
                ALUControlD = 4'b1011; // ADD + clear LSB for JALR
            end

            // AUIPC  (Op = 0010111)
            // rd = PC + {imm, 12'b0}
            7'b0010111: begin
                RegWriteD     = 1'b1;
                ImmSrcD       = 3'b100;   // U-immediate
                ALUSrcD       = 1'b1;
                ResultSrcD   = 2'b11;
                MemWriteD     = 1'b0;
                BranchD       = 1'b0;
                JumpD          = 1'b0;
                MemEnD       = 1'b0;
                CSRSrcD       = 1'b0;
                ALUControlD   = 4'b0000; // ADD (PC + imm)
            end

            // CSRRS  (Op = 1110011)
            // rd = CSR[addr]; CSR[addr] |= rs1
            7'b1110011: begin
                RegWriteD     = 1'b1;    // write CSR value to rd
                ImmSrcD       = 3'b000;  // unused
                ALUSrcD       = 1'b0;
                ResultSrcD   = 2'b00;
                MemWriteD     = 1'b0;
                BranchD       = 1'b0;
                JumpD          = 1'b0;
                MemEnD       = 1'b0;
                ALUControlD   = 4'b0000;
                CSRSrcD       = 1'b1;    // select CSR result into result mux
            end

            // For unimplemented instructions
            default: begin
`ifdef DEBUG
                if (insn_debug !== 'x) begin
                    $display("Instruction not implemented: %h", insn_debug);
                    $finish(-1);
                end
`endif
            end
        endcase
    end

endmodule
