// mux.sv
// RISC-V pipelined processor
// pclark@hmc.edu mconine@hmc.edu 2026

module mux2 #(parameter WIDTH = 8) (
  input  logic [WIDTH-1:0] d0, d1,
  input  logic             s,
  output logic [WIDTH-1:0] y);

  assign y = s ? d1 : d0;
endmodule

module mux3 #(parameter WIDTH = 8) (
  input  logic [WIDTH-1:0] d0, d1, d2,
  input  logic [1:0]       s,
  output logic [WIDTH-1:0] y);

  assign y = s[1] ? d2 : (s[0] ? d1 : d0); // exclusion-tag: mux3
endmodule

module mux4 #(parameter WIDTH = 8) (
  input  logic [WIDTH-1:0] d0, d1, d2, d3,
  input  logic [1:0]       s,
  output logic [WIDTH-1:0] y);

  assign y = s[1] ? (s[0] ? d3 : d2) : (s[0] ? d1 : d0);
endmodule
