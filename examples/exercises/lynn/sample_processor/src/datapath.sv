// datapath.sv
module datapath(
        input   logic           clk, reset,
        input   logic [2:0]     Funct3,
        input   logic           ALUResultSrc, ResultSrc,
        input   logic [1:0]     ALUSrc,
        input   logic           RegWrite,
        input   logic           MemWrite,
        input   logic [2:0]     ImmSrc,
        input   logic [4:0]     ALUControl,
        output  logic [2:0]     Flags,
        input   logic [31:0]    PC, PCPlus4,
        input   logic [31:0]    Instr,
        output  logic [31:0]    IEUAdr, WriteData,
        input   logic [31:0]    ReadData,
        input   logic           CSRSrc, PCSrc,
        output logic [3:0] WriteByteEn
    );

    logic [31:0] ImmExt;
    logic [31:0] R1, R2, SrcA, SrcB;
    logic [31:0] ALUResult, IEUResult, Result;
    logic [7:0]  ByteM;
    logic [15:0] HalfwordM;
    logic [31:0] LoadData;
    logic [31:0] CSRReadData, CSRResult;

    // register file logic
    regfile rf(.clk, .WE3(RegWrite), .A1(Instr[19:15]), .A2(Instr[24:20]),
        .A3(Instr[11:7]), .WD3(Result), .RD1(R1), .RD2(R2));

    //csrfile
    csrfile csr(.clk, .reset, .CSRWrite(CSRSrc), .CSRAdr(Instr[31:20]),
        .RS1(R1), .RetiredInstr(~reset), .Op(Instr[6:0]), .Funct3(Instr[14:12]), .Funct7(Instr[31:25]), .PCSrc,.CSRReadData);

    //extentender chicken nuggets
    extend ext(.Instr(Instr[31:7]), .ImmSrc, .ImmExt);

    // Comparitor and ALU
    cmp cmp(.R1, .R2, .Flags);
    mux2 #(32) srcamux(R1, PC, ALUSrc[1], SrcA);
    mux2 #(32) srcbmux(R2, ImmExt, ALUSrc[0], SrcB);
    alu alu(.SrcA, .SrcB, .ALUControl, .ALUResult, .IEUAdr);

    // -------------------------------------------------------------------------
    // Subword Read — select and sign/zero extend based on Funct3 and address
    // -------------------------------------------------------------------------
    mux2 #(16) halfwordmux(ReadData[15:0], ReadData[31:16], IEUAdr[1], HalfwordM);
    mux2 #(8)  bytemux(HalfwordM[7:0], HalfwordM[15:8],    IEUAdr[0], ByteM);

    always_comb
        case (Funct3)
            3'b000: LoadData = {{24{ByteM[7]}},      ByteM};      // LB
            3'b001: LoadData = {{16{HalfwordM[15]}}, HalfwordM};  // LH
            3'b010: LoadData = ReadData;                           // LW
            3'b100: LoadData = {24'b0, ByteM};                    // LBU
            3'b101: LoadData = {16'b0, HalfwordM};                // LHU
            default: LoadData = ReadData;
        endcase

    // -------------------------------------------------------------------------
    // Subword Write — replicate data into correct lanes
    // -------------------------------------------------------------------------
    always_comb
        case (Funct3)
            3'b000: WriteData = {4{R2[7:0]}};  // SB — byte replicated to all lanes
            3'b001: WriteData = {2{R2[15:0]}}; // SH — half replicated to both halves
            3'b010: WriteData = R2;            // SW — full word
            default: WriteData = R2;
        endcase

    // -------------------------------------------------------------------------
    // Byte enables — gated by MemWrite, shifted by address offset
    // -------------------------------------------------------------------------
    always_comb
        if (!MemWrite) WriteByteEn = 4'b0000;
        else case (Funct3)
            3'b000: WriteByteEn = 4'b0001 << IEUAdr[1:0];        // SB — 1 byte at offset
            3'b001: WriteByteEn = 4'b0011 << {IEUAdr[1], 1'b0};  // SH — 2 bytes at half offset
            3'b010: WriteByteEn = 4'b1111;                        // SW — all bytes
            default: WriteByteEn = 4'b1111;
        endcase

    //Result Muxs
    mux2 #(32) ieuresultmux(ALUResult, PCPlus4, ALUResultSrc, IEUResult);
    mux2 #(32) csrmux(IEUResult, CSRReadData, CSRSrc, CSRResult);
    mux2 #(32) resultmux(CSRResult, LoadData, ResultSrc, Result);
endmodule
