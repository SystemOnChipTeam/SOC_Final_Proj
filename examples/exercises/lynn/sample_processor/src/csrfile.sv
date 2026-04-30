// csrfile.sv
// RISC-V multi-cycle processor
// Max Conine and Pierce Clark
// pclark@hmc.edu mconine@hmc.edu 2026

// Optimized area for coremark test by removing custom telemetry counters.
module csrfile (
    input  logic        clk, reset,
    input  logic [11:0] CSRAdr,        // CSR address from Instr[31:20]
    input  logic        RetiredInstr,  // pulse high each retired instruction
    output logic [31:0] CSRReadData    // CSR value to write to rd
);

  // Zicntr CSR addresses (Standard Read-Only)
  localparam RDCYCLE    = 12'hC00;
  localparam RDCYCLEH   = 12'hC80;
  localparam RDTIME     = 12'hC01;
  localparam RDTIMEH    = 12'hC81;
  localparam RDINSTRET  = 12'hC02;
  localparam RDINSTRETH = 12'hC82;

  // Counter registers
  logic [63:0] cycle_count;
  logic [63:0] instret_count;

  // Zicntr
  always_ff @(posedge clk) begin
    if (reset) begin
      cycle_count   <= 64'b0;
      instret_count <= 64'b0;
    end else begin
      cycle_count <= cycle_count + 1;
      if (RetiredInstr) instret_count <= instret_count + 1;
    end
  end

  always_comb begin
    case (CSRAdr)
      // Standard Zicntr counters
      RDCYCLE:    CSRReadData = cycle_count[31:0];
      RDCYCLEH:   CSRReadData = cycle_count[63:32];
      RDTIME:     CSRReadData = cycle_count[31:0];
      RDTIMEH:    CSRReadData = cycle_count[63:32];
      RDINSTRET:  CSRReadData = instret_count[31:0];
      RDINSTRETH: CSRReadData = instret_count[63:32];
      default:    CSRReadData = 32'b0;
    endcase
  end

endmodule
