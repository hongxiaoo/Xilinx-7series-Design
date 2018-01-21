// pipeline register using SRL32/SRL16 of SLICEM
// dont use set/reset control set or ASYNC_REG to map to SRL32/16
// use attribute for reg_srl / reg_srl_reg / srl_reg
module pipeline_reg #(
  parameter SYNC_STAGE = 32
) (
  input  logic clk,
  input  logic din,
  output logic dout
);

  logic [SYNC_STAGE-1:0] sync_reg;
  always_ff @(posedge clk) begin
    sync_reg <= {sync_reg[SYNC_STAGE-2:0],din};
  end
  assign dout = sync_reg[SYNC_STAGE-1];
  
endmodule
// Reset-Sync : Async-assert and sync-deassert
// Min 3 stage pipeline to mitegate reset recovery and removal time
// use set_max_delay constraint for async_reset from source to FF/d with period min(clk1,clk2)
module reset_sync #(
  parameter SYNC_STAGE = 3
) (
  input  logic clk,
  input  logic async_reset,
  output logic sync_reset
);
  
  (* ASYNC_REG = "TRUE" *) logic [SYNC_STAGE-1:0] sync_reg;
  always_ff @(posedge clk or posedge async_reset) begin
    if (async_reset) begin
      sync_reg <= {SYNC_STAGE{1'b1}};
    end else begin
      sync_reg <= {sync_reg[SYNC_STAGE-2:0],1'b0};
    end
  end
  assign sync_reset = sync_reg[SYNC_STAGE-1];
  
endmodule
// Resetn-Sync : Async-assert and sync-deassert
// Min 3 stage pipeline to mitegate reset recovery and removal time
module resetn_sync #(
  parameter SYNC_STAGE = 3
) (
  input  logic clk,
  input  logic async_resetn,
  output logic sync_resetn
);
  
  (* ASYNC_REG = "TRUE" *) logic [SYNC_STAGE-1:0] sync_reg;
  always_ff @(posedge clk or negedge async_resetn) begin
    if (!async_resetn) begin
      sync_reg <= {SYNC_STAGE{1'b0}};
    end else begin
      sync_reg <= {sync_reg[SYNC_STAGE-2:0],1'b1};
    end
  end
  assign sync_resetn = sync_reg[SYNC_STAGE-1];
  
endmodule
