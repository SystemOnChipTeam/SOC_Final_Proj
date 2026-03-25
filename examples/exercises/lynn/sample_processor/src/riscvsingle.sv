// riscvsingle.sv
// RISC-V multi-cycle processor
// Max Conine and Pierce Clark

`include "parameters.svh"

module riscvsingle (
        input   logic           clk,
        input   logic           reset,

        output  logic [31:0]    PC,  // instruction memory target address
        input   logic [31:0]    Instr, // instruction memory read data

        output  logic [31:0]    IEUAdr,  // data memory target address
        input   logic [31:0]    ReadData, // data memory read data
        output  logic [31:0]    WriteData, // data memory write data

        output  logic           MemEn,
        output  logic           WriteEn,
        output  logic [3:0]     WriteByteEn  // strobes, 1 hot stating weather a byte should be written on a store
    );

    logic [31:0] PCPlus4;
    logic PCSrc;
    logic Load;

    ifu ifu(.clk, .reset,
        //inputs
        .StallF, .StallD .FlushD,
        .PCSrcE, .IEUAdrE,

        //outputs
        .PCD, .InstrD
    );

    ieu ieu(.clk, .reset,
        //inputs
        .StallE, .FlushE, .ForwardedSrcAE, .ForwardedSrcBE,
        .PCD, .InstrD, .RdW, 
		
		RegWriteW, ResultSrcW, 

        //outputs
        .PCSrcE, .IEUAdrE,
        .MemRWE, .ResultSrcE, .RegWriteE,
        .WriteByteEn, .MemEn

        //Previous
        .Instr, .PC, .PCPlus4, .PCSrc, .WriteByteEn,
            .IEUAdr, .WriteData, .ReadData, .MemEn
        );

    lsu lsu(.clk, .reset,
    	//inputs
		.FlushM, .StallM, .MemRWE, .ResultSrcE, .RegWriteE, .IEUResultE, .FSrcBE, .IEUAdrE, .Funct3E, .RdE,

    	//outputs
		.RegWriteW, .ResultSrcW, .IEUResultW, .IEUResultM, .ReadDataW, .RdW
    );

    //pipeline registers


    hazard hzu();

    assign WriteEn = |WriteByteEn;
endmodule
