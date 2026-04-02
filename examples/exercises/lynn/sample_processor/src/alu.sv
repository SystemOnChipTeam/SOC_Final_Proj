// alu.sv
// RISC-V pipelined processor
// pclark@hmc.edu mconine@hmc.edu 2026

module alu(
    input  logic [31:0] SrcA, SrcB,
    input  logic [4:0]  ALUControl,
    output logic [31:0] ALUResult
);

    // Adder / Subtractor
    logic        Sub;
    logic [31:0] CondInvB, Sum;

    assign Sub = (ALUControl == 5'b00001) | // SUB
             (ALUControl == 5'b00011) | // SLT
             (ALUControl == 5'b00100);  // SLTU

    assign CondInvB = Sub ? ~SrcB : SrcB;
    assign Sum      = SrcA + CondInvB + {31'b0, Sub};

    // Signed less-than (SLT) — overflow-aware
    logic Overflow, Neg, LT;

    assign Overflow = (~(SrcA[31] ^ SrcB[31] ^ Sub)) & (SrcA[31] ^ Sum[31]);
    assign Neg      = Sum[31];
    assign LT       = Neg ^ Overflow;

    // Shift amount — bottom 5 bits of SrcB (rs2 or shamt immediate)
    logic [4:0] Shamt;
    assign Shamt = SrcB[4:0];

    //multiply logic
    logic [63:0]        mul_unsigned;
    logic signed [63:0] mul_signed;
    logic signed [63:0] mul_mixed;

    assign mul_unsigned = {32'b0, SrcA} * {32'b0, SrcB};
    assign mul_signed   = $signed({{32{SrcA[31]}}, SrcA}) * $signed({{32{SrcB[31]}}, SrcB});
    assign mul_mixed    = $signed({{32{SrcA[31]}}, SrcA}) * $signed({32'b0, SrcB});

    // Result mux
    always_comb begin
        case (ALUControl)
            5'b00000: ALUResult = Sum;           // ADD / ADDI / LW / SW
            5'b00001: ALUResult = Sum;           // SUB / BEQ
            5'b00010: ALUResult = SrcA << Shamt; // SLL / SLLI
            5'b00011: ALUResult = {31'b0, LT};   // SLT / SLTI
            5'b00100: ALUResult = {31'b0, (SrcA < SrcB)}; // SLTU / SLTIU (unsigned)
            5'b00101: ALUResult = SrcA ^ SrcB; // XOR / XORI
            5'b00110: ALUResult = SrcA >> Shamt;  // SRL / SRLI
            5'b00111: ALUResult = $signed(SrcA) >>> Shamt; // SRA / SRAI
            5'b01000: ALUResult = SrcA | SrcB;   // OR  / ORI
            5'b01001: ALUResult = SrcA & SrcB;   // AND / ANDI
            5'b01010: ALUResult = SrcB;          // LUI (pass upper-immediate)
            5'b01011: ALUResult = {Sum[31:1], 1'b0}; // JALR — rs1 + imm, LSB cleared

            //multiply instruction
            5'b01100: ALUResult = mul_unsigned[31:0];  // MUL
            5'b01101: ALUResult = mul_signed[63:32];   // MULH
            5'b01110: ALUResult = mul_mixed[63:32]; // MULHSU
            5'b01111: ALUResult = mul_unsigned[63:32];    // MULHU

            default:  ALUResult = 'x;
        endcase
    end

endmodule
