// distributed RAM mapped to SLICEM stores 64x1 or 32x2
// distributed RAM supports Sync-Write and Async-Read
// block RAM only supports Sync-Write and Read
// if the DATA_WIDTH > 16 bit use Block-RAM
module spram #(
  parameter RAM_STYLE = "distributed"
  parameter DATA_WIDTH = 2, // > 16 need to use BRAM
  parameter ADDR_WIDTH = 5
  ) (
  input  logic clk,
  input  logic we,
  input  logic [ADDR_WIDTH-1:0] addr,
  input  logic [DATA_WIDTH-1:0] din,
  output logic [DATA_WIDTH-1:0] dout
  );
  
endmodule
