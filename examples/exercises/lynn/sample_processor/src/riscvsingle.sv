// riscvsingle.sv
// RISC-V pipelined processor
// pclark@hmc.edu mconine@hmc.edu 2026

`include "parameters.svh"

module riscvsingle (
        input   logic           clk, reset,
        // Instruction Memory Interface
        output  logic [31:0]    PC,  // instruction memory target address
        input   logic [31:0]    Instr, // instruction memory read data

        // Data Memory Interface
        output  logic [31:0]    IEUAdr,  // data memory target address
        input   logic [31:0]    ReadData, // data memory read data
        output  logic [31:0]    WriteData, // data memory write data
        output  logic           MemEn,
        output  logic           WriteEn,
        output  logic [3:0]     WriteByteEn  // strobes, 1 hot stating weather a byte should be written on a store
    );

    // IFU to IEU
    logic [31:0] InstrD, PCD, PCPlus4D;

    // IEU to IFU
    logic        PCSrcE;
    logic [31:0] PCTargetE;

    // IEU to LSU (Execute stage)
    logic        MemEnE, RegWriteE, MemWriteE;
    logic [1:0]  ResultSrcE;
    logic [31:0] ALUResultE, WriteDataE, PCPlus4E;
    logic [2:0]  Funct3E;
    logic [4:0]  RdE;

    // LSU to IEU (Memory stage, for forwarding)
    logic [31:0] ALUResultM;
    assign IEUAdr = ALUResultM;

    // LSU to IEU (Writeback stage)
    logic        RegWriteW;
    logic [1:0]  ResultSrcW;
    logic [31:0] ALUResultW, ReadDataW, PCPlus4W;
    logic [4:0]  RdW;
    logic [31:0] PCTargetW;

    // Hazard unit outputs to IFU/IEU/LSU
    logic        StallF, StallD, FlushD;
    logic        StallE, FlushE;
    logic [1:0]  ForwardAE, ForwardBE;
    logic        StallM, FlushM;
    logic        StallW, FlushW;

    // Hazard unit inputs from IEU/LSU
    logic [4:0]  Rs1D, Rs2D;
    logic [4:0]  Rs1E, Rs2E;
    logic        ResultSrcE0;
    logic [4:0]  RdM;
    logic        RegWriteM;
    logic        MulWorking;

    ifu ifu(
        .clk, .reset,
        // Hazard unit
        .StallF, .StallD, .FlushD,
        // From Execute stage
        .PCSrcE,
        .PCTargetE,
        // Outputs to Decode stage
        .InstrD, .PCD, .PCPlus4D,
        // Instruction memory interface
        .PCF(PC),
        .InstrF(Instr)
    );

    ieu ieu(
        .clk, .reset,
        // Decode stage inputs
        .InstrD, .PCD, .PCPlus4D,
        // Execute stage outputs
        .MemEnE, .RegWriteE, .ResultSrcE, .MemWriteE,
        .ALUResultE, .WriteDataE, .Funct3E, .PCPlus4E,
        .PCTargetE,
        // Memory stage input (forwarding)
        .StallM, .FlushM, .ALUResultM,
        // Writeback stage inputs
        .RegWriteW, .ResultSrcW,
        .ALUResultW, .ReadDataW, .PCPlus4W, .RdW, .PCTargetW,
        // Hazard unit — Decode
        .Rs1D, .Rs2D,
        // Hazard unit — Execute
        .StallE, .FlushE,
        .ForwardAE, .ForwardBE,
        .Rs1E, .Rs2E, .RdE,
        .PCSrcE,
        .ResultSrcE0,
        .MulWorking
    );

    lsu lsu(
        .clk, .reset,
        // Execute stage inputs
        .MemEnE, .RegWriteE, .ResultSrcE, .MemWriteE,
        .ALUResultE, .WriteDataE, .RdE, .PCPlus4E, .Funct3E, .PCTargetE,
        .StallM, .FlushM,
        .StallW, .FlushW,
        .RdM, .RegWriteM,
        // Writeback outputs to IEU
        .RegWriteW, .ResultSrcW,
        .ALUResultW, .ReadDataW, .PCPlus4W, .RdW, .PCTargetW,
        // DTIM interface
        .ALUResultM,
        .DataOutM(ReadData),
        .DataInM(WriteData),
        .MemEnM(MemEn),
        .MemWriteM(WriteEn),
        .WriteByteEn(WriteByteEn)
    );

    hazard hzu(
        // Inputs
        .clk, .reset,
        // Decode stage
        .Rs1D, .Rs2D,
        // Execute stage
        .Rs1E, .Rs2E, .RdE,
        .PCSrcE,
        .ResultSrcE0,
        .MulBusy(MulWorking),
        // Memory stage
        .RdM, .RegWriteM,
        // Writeback stage
        .RegWriteW, .RdW,
        // Stall outputs
        .StallF, .StallD,
        // Flush outputs
        .FlushD, .FlushE,
        // Stall execute
        .StallE,
        // Forwarding
        .ForwardAE, .ForwardBE,
        .StallM, .FlushM,
        .StallW, .FlushW
    );

endmodule
