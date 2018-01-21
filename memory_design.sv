// distributed RAM mapped to SLICEM stores 64x1 or 32x2
// distributed RAM supports Sync-Write and Async-Read
// block RAM only supports Sync-Write and Read
// if the DATA_WIDTH > 16 bit use Block-RAM
module spram #(
  parameter RAM_STYLE = "distributed"
  parameter REG_RPORT = 1,  // Async-read supported only in distributed RAM
  parameter DATA_WIDTH = 2, // > 16 need to use BRAM
  parameter ADDR_WIDTH = 5
  ) (
  input  logic clk,
  input  logic we,
  input  logic [ADDR_WIDTH-1:0] addr,
  input  logic [DATA_WIDTH-1:0] din,
  output logic [DATA_WIDTH-1:0] dout
  );
  
  (* ram_style = RAM_STYLE *)
  logic [DATA_WIDTH-1:0] mem [2**ADDR_WIDTH];
  always_ff @(posedge clk) begin
    if (we) begin
      mem[addr] <= din;
    end
  end
  generate if (REG_RPORT) begin
    always_ff @(posedge clk) begin
      dout <= mem[addr];
    end
  end else begin
    assign dout = mem[addr];
  end endgenerate
  
endmodule

module dpram #(
  parameter RAM_STYLE = "distributed"
  parameter REG_RPORT = 1,  // Async-read supported only in distributed RAM
  parameter DATA_WIDTH = 2, // > 16 need to use BRAM
  parameter ADDR_WIDTH = 5
  ) (
  input  logic aclk,
  input  logic awe,
  input  logic [ADDR_WIDTH-1:0] aaddr,
  input  logic [DATA_WIDTH-1:0] adin,
  output logic [DATA_WIDTH-1:0] adout,
  input  logic bclk,
  input  logic [ADDR_WIDTH-1:0] baddr,
  output logic [DATA_WIDTH-1:0] bdout
  );
  
  (* ram_style = RAM_STYLE *)
  logic [DATA_WIDTH-1:0] mem [2**ADDR_WIDTH];
  always_ff @(posedge aclk) begin
    if (awe) begin
      mem[aaddr] <= adin;
    end
  end
  generate if (REG_RPORT) begin
    always_ff @(posedge aclk) begin
      adout <= mem[aaddr];
    end
    always_ff @(posedge bclk) begin
      bdout <= mem[baddr];
    end
  end else begin
    assign adout = mem[aaddr];
    assign bdout = mem[baddr];
  end endgenerate
  
endmodule
