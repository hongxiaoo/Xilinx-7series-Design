// distributed RAM mapped to SLICEM stores 64x1 or 32x2
// distributed RAM supports Sync-Write and Async-Read
// block RAM only supports Sync-Write and Read
// if the DATA_WIDTH > 16 bit use Block-RAM
// if the ADDR_WIDTH > 8 (2^8=256) bit use Block-RAM
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
// Block RAM buliding blocks are RAMB36K or 2-RAMB18K
module sp_bram_2K_18 #(
  parameter DATA_WIDTH = 18, // > 16 need to use BRAM
  parameter ADDR_WIDTH = 11
  ) (
  input  logic clk,
  input  logic we,
  input  logic [ADDR_WIDTH-1:0] addr,
  input  logic [DATA_WIDTH-1:0] din,
  output logic [DATA_WIDTH-1:0] dout
  );
  
  (* ram_style = "block" *)
  logic [DATA_WIDTH-1:0] mem [2**ADDR_WIDTH];
  always_ff @(posedge clk) begin
    if (we) begin
      mem[addr] <= din;
    end
  end
  always_ff @(posedge clk) begin
    dout <= mem[addr];
  end
  
endmodule
// RTL modelling for Wider-Data-Width
module sp_bram_2K_1024 #(
  parameter DATA_WIDTH = 1024, // > 16 need to use BRAM
  parameter ADDR_WIDTH = 11
  ) (
  input  logic clk,
  input  logic we,
  input  logic [ADDR_WIDTH-1:0] addr,
  input  logic [DATA_WIDTH-1:0] din,
  output logic [DATA_WIDTH-1:0] dout
  );
  
  localparam NO_RAM = (DATA_WIDTH/18)*18 <= DATA_WIDTH ? DATA_WIDTH/18 : (DATA_WIDTH/18)+1;
  
  generate for(genvar i=0; i<NO_RAM; i++) begin : gen_bram
    sp_bram_2K_18 sp_bram_2K_18 (
      .clk (clk),
      .we  (we),
      .addr(addr),
      .din (din [18*i+:18]),
      .dout(dout[18*i+:18])
    );
  end endgenerate
  
endmodule
// RTL modelling for Wider-Data-Width and cascading of BRAM
module sp_bram_4K_1024 #(
  parameter DATA_WIDTH = 1024, // > 16 need to use BRAM
  parameter ADDR_WIDTH = 12
  ) (
  input  logic clk,
  input  logic we,
  input  logic [ADDR_WIDTH-1:0] addr,
  input  logic [DATA_WIDTH-1:0] din,
  output logic [DATA_WIDTH-1:0] dout
  );
  
  localparam NO_RAM = (DATA_WIDTH/18)*18 <= DATA_WIDTH ? DATA_WIDTH/18 : (DATA_WIDTH/18)+1;
  logic [DATA_WIDTH-1:0] dout0;
  logic [DATA_WIDTH-1:0] dout1;
  
  generate for(genvar i=0; i<NO_RAM; i++) begin : gen_bram
    sp_bram_2K_18 sp_bram_2K_18_Bank0 (
      .clk (clk),
      .we  (we && ~addr[11]),
      .addr(addr [10:0]),
      .din (din  [18*i+:18]),
      .dout(dout0[18*i+:18])
    );
    sp_bram_2K_18 sp_bram_2K_18_Bank1 (
      .clk (clk),
      .we  (we &&  addr[11]),
      .addr(addr [10:0]),
      .din (din  [18*i+:18]),
      .dout(dout1[18*i+:18])
    );
  end endgenerate
  assign dout = addr[11] ? dout0 : dout1;
    
endmodule
