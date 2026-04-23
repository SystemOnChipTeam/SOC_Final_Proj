// ifu.sv
// RISC-V pipelined processor
// modified to include dynamic branch prediction

module ifu (
    // Inputs
    input logic clk,
    reset,

    // --- Execute Stage Signals ---
    input logic        PCSrcE,        // Actual direction (1 if taken)
    input logic [31:0] PCTargetE,     // Target address calculated in E
    input logic [31:0] PCE,           // PC of the instruction currently in E
    input logic        BranchE,       // 1 if instruction in E is a branch
    input logic        PredictTakenE, // Pipelined prediction bit from F -> D -> E

    // Stalls & Flushes
    input logic StallF,
    input logic StallD,
    input logic FlushD,

    // Outputs
    output logic [31:0] InstrD,
    output logic [31:0] PCD,
    output logic [31:0] PCPlus4D,
    output logic        PredictTakenD, // Pass prediction to Decode stage

    // Memory interface
    output logic [31:0] PCF,
    input  logic [31:0] InstrF
);

  logic [31:0] PCNext, PCPlus4F;
  logic [31:0] entry_addr;
  logic        PredictTakenF;
  logic [31:0] PredictedTargetF;
  logic        MispredictE;

  logic        BTBHitF;

  // --- E to M Stage Pipeline Registers for BTB Update ---
  logic [31:0] PCM, PCTargetM;
  logic        BranchM, ActualTakenM;

  always_ff @(posedge clk) begin
      if (reset) begin
          PCM          <= '0;
          PCTargetM    <= '0;
          BranchM      <= 1'b0;
          ActualTakenM <= 1'b0;
      end else begin
          PCM          <= PCE;
          PCTargetM    <= PCTargetE;
          BranchM      <= BranchE;
          ActualTakenM <= PCSrcE;
      end
  end

  // --- Initialization ---
  initial begin
    entry_addr = '0;
    void'($value$plusargs("ENTRY_ADDR=%h", entry_addr));
    $display("[TB] ENTRY_ADDR = 0x%h", entry_addr);
  end

  // branch predictor
  two_bit_predictor bp (
      .clk(clk),
      .reset(reset),
      .PCF(PCF),
      .PredictTakenF(PredictTakenF),
      .PCM(PCM),
      .BranchM(BranchM),
      .ActualTakenM(ActualTakenM)
  );

  btb branch_buffer (
      .clk(clk),
      .reset(reset),
      .PCF(PCF),
      .PredictedTargetF(PredictedTargetF),
      .BTBHitF(BTBHitF),
      .PCM(PCM),
      .PCTargetM(PCTargetM),
      .UpdateBTBM(BranchM)
  );

  assign MispredictE = BranchE ? (PCSrcE != PredictTakenE) : PCSrcE;

  // Priority 1: Misprediction Recovery
  // Priority 2: Predicted branch taken
  // Priority 3: Default PC+4
  always_comb begin
    if (MispredictE) begin
      // If we mispredicted, where should we go?
      if (PCSrcE) PCNext = PCTargetE;  // We predicted NT, but it was Taken
      else PCNext = PCE + 4;  // We predicted T, but it was Not Taken
    end else if (PredictTakenF && BTBHitF) begin
      PCNext = PredictedTargetF;
    end else begin
      PCNext = PCPlus4F;  // Default sequential execution
    end
  end

  always_ff @(posedge clk) begin
    if (reset) PCF <= entry_addr;
    else if (~StallF) PCF <= PCNext;
  end

  adder PCadd4f (
      PCF,
      32'd4,
      PCPlus4F
  );

  flopenrc #(32) InstrDReg (
      clk,
      reset,
      FlushD,
      ~StallD,
      InstrF,
      InstrD
  );
  flopenrc #(32) PCDReg (
      clk,
      reset,
      FlushD,
      ~StallD,
      PCF,
      PCD
  );
  flopenrc #(32) PCPlus4DReg (
      clk,
      reset,
      FlushD,
      ~StallD,
      PCPlus4F,
      PCPlus4D
  );

  // Pipeline the prediction
  flopenrc #(1) PredDReg (
      clk,
      reset,
      FlushD,
      ~StallD,
      (PredictTakenF & BTBHitF),
      PredictTakenD
  );
endmodule
