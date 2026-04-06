// alu.sv
// RISC-V pipelined processor
// pclark@hmc.edu mconine@hmc.edu 2026

module alu(
    input  logic [31:0] SrcA, SrcB,
    input  logic [3:0]  ALUControl,
    output logic [31:0] ALUResult
);

    // Adder / Subtractor
    logic        Sub;
    logic [31:0] CondInvB, Sum;

    assign Sub = (ALUControl == 4'b0001) | // SUB
                (ALUControl == 4'b0011) | // SLT
                (ALUControl == 4'b0100);  // SLTU

    assign CondInvB = Sub ? ~SrcB : SrcB;
    assign Sum      = SrcA + CondInvB + {31'b0, Sub};

    // Flags
    logic Overflow, Neg, LT;

    assign Overflow = (~(SrcA[31] ^ SrcB[31] ^ Sub)) & (SrcA[31] ^ Sum[31]);
    assign Neg      = Sum[31];
    assign LT       = Neg ^ Overflow;

    // Shift amount — bottom 5 bits of SrcB (rs2 or shamt immediate)
    logic [3:0] Shamt;
    assign Shamt = SrcB[3:0];

    // Result mux
    always_comb begin
        case (ALUControl)
            4'b0000: ALUResult = Sum;                      // ADD / ADDI / LW / SW
            4'b0001: ALUResult = Sum;                      // SUB / BEQ
            4'b0010: ALUResult = SrcA << Shamt;            // SLL / SLLI
            4'b0011: ALUResult = {31'b0, LT};              // SLT / SLTI
            4'b0100: ALUResult = {31'b0, (SrcA < SrcB)};   // SLTU / SLTIU (unsigned)
            4'b0101: ALUResult = SrcA ^ SrcB;              // XOR / XORI
            4'b0110: ALUResult = SrcA >> Shamt;            // SRL / SRLI
            4'b0111: ALUResult = $signed(SrcA) >>> Shamt;  // SRA / SRAI
            4'b1000: ALUResult = SrcA | SrcB;              // OR  / ORI
            4'b1001: ALUResult = SrcA & SrcB;              // AND / ANDI
            4'b1010: ALUResult = SrcB;                     // LUI (pass upper-immediate)
            4'b1011: ALUResult = {Sum[31:1], 1'b0};        // JALR — rs1 + imm, LSB cleared
            default:  ALUResult = 'x;
        endcase
    end

endmodule
