// riscvsingle.sv
// RISC-V pipelined processor
// Max Conine and Pierce Clark
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

    // Branch Prediction Signals (Replaces PCSrcE and PCTargetE)
    logic        PredictTakenD;
    logic [31:0] PredictedTargetD;
    logic        MispredictE;
    logic [31:0] RecoveryPCE;

    // IEU to LSU (Execute stage)
    logic        MemEnE, RegWriteE, MemWriteE;
    logic [31:0] ALUResultE, WriteDataE;
    logic [2:0]  Funct3E;
    logic [4:0]  RdE;

    // LSU to IEU (Memory stage, for forwarding)
    logic [31:0] ALUResultM;
    assign IEUAdr = ALUResultM;

    // LSU to IEU (Writeback stage)
    logic        RegWriteW;
    logic [31:0] ALUResultW, ReadDataW;
    logic [4:0]  RdW;

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
        // Branch Prediction Interface
        .PredictTakenD,
        .PredictedTargetD,
        .MispredictE,
        .RecoveryPCE,
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
        .MemEnE, .RegWriteE, .MemWriteE,
        .ALUResultE, .WriteDataE, .Funct3E,
        // Memory stage input (forwarding)
        .ALUResultM,
        // Writeback stage inputs
        .RegWriteW,
        .ALUResultW, .ReadDataW, .RdW,
        // Hazard unit — Decode
        .Rs1D, .Rs2D,
        // Hazard unit — Execute
        .StallE, .FlushE, .StallM, .FlushM, .StallW, .FlushW,
        .ForwardAE, .ForwardBE,
        .Rs1E, .Rs2E, .RdE,
        // Branch Prediction
        .PredictTakenD,
        .PredictedTargetD,
        .MispredictE,
        .RecoveryPCE,
        .ResultSrcE0,
        .MulWorking
    );

    lsu lsu(
        .clk, .reset,
        // Execute stage inputs
        .MemEnE, .RegWriteE, .MemWriteE,
        .ALUResultE, .WriteDataE, .RdE, .Funct3E,
        .StallM, .FlushM,
        .StallW, .FlushW,
        .RdM, .RegWriteM,
        // Writeback outputs to IEU
        .RegWriteW,
        .ALUResultW, .ReadDataW, .RdW,
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
        // Decode stage
        .Rs1D, .Rs2D,
        .PredictTakenD,
        // Execute stage
        .Rs1E, .Rs2E, .RdE,
        .MispredictE,
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
