module add_sub #(
  parameter DATA_WIDTH = 8
) (
  input  logic clk,
  input  logic mode, // 0/1 = ADD/SUB
  input  logic [DATA_WIDTH-1:0] a,
  input  logic [DATA_WIDTH-1:0] b,
  output logic [DATA_WIDTH-0:0] sum
);

endmodule
