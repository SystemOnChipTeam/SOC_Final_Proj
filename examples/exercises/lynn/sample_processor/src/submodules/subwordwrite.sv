module subwordwrite(
    input  logic [31:0] WriteVal,   // R2 from register file
    input  logic [1:0]  PAdr,       // IEUAdr[1:0]
    input  logic [2:0]  Funct3,
    input  logic        MemWrite,
    output logic [31:0] WriteData,
    output logic [3:0]  WriteByteEn
);
    always_comb begin
        if (!MemWrite) begin
            WriteData   = WriteVal;
            WriteByteEn = 4'b0000;
        end else begin
            case (Funct3)
                3'b000: begin  // SB
                    WriteData   = {4{WriteVal[7:0]}};
                    WriteByteEn = 4'b0001 << PAdr;
                end
                3'b001: begin  // SH
                    WriteData   = {2{WriteVal[15:0]}};
                    WriteByteEn = 4'b0011 << {PAdr[1], 1'b0};
                end
                3'b010: begin  // SW
                    WriteData   = WriteVal;
                    WriteByteEn = 4'b1111;
                end
                default: begin
                    WriteData   = WriteVal;
                    WriteByteEn = 4'b1111;
                end
            endcase
        end
    end
endmodule
