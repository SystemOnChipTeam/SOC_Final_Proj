// ieu.sv

module ieu(
        input   logic           clk, reset,
        input   logic [31:0]    Instr,
        input   logic [31:0]    PC, PCPlus4,
        output  logic           PCSrc,
        output  logic [3:0]     WriteByteEn,
        output  logic [31:0]    IEUAdr, WriteData,
        input   logic [31:0]    ReadData,
        output  logic           MemEn
    );

    logic RegWrite, MemWrite, Jump, ALUResultSrc, ResultSrc,CSRSrc;
    logic [1:0] ALUSrc;
    logic [2:0] Flags;
    logic [2:0] ImmSrc;
    logic [4:0] ALUControl;

    controller c(.Op(Instr[6:0]), .Funct3(Instr[14:12]), .Funct7(Instr[31:25]), .Flags,
        .ALUResultSrc, .ResultSrc, .PCSrc,
        .ALUSrc, .RegWrite, .MemWrite, .ImmSrc, .ALUControl, .MemEn, .CSRSrc
    );

    datapath dp(.clk, .reset, .Funct3(Instr[14:12]),
        .ALUResultSrc, .ResultSrc, .ALUSrc, .RegWrite, .MemWrite, .ImmSrc, .ALUControl, .Flags,
        .PC, .PCPlus4, .Instr, .IEUAdr, .WriteData, .ReadData, .CSRSrc, .PCSrc, .WriteByteEn);
endmodule
