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
// use set_max_delay constraint for async_reset from source to FF/d with period min(clk1,clk2)
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
// Data-Sync : synchronize single-bit data
// Min 3 stage pipeline to mitegate metastability due to setup and hold time violations
// use ASYNC_REG and max_delay[with min-period(freq1,freq2)] constraint with async-clock groups {clk1,clk2}
module data_sync #(
  parameter SYNC_STAGE = 3
) (
  input  logic clk,
  input  logic din,
  output logic dout
);
  
  (* ASYNC_REG = "TRUE" *) logic [SYNC_STAGE-1:0] sync_reg;
  always_ff @(posedge clk) begin
    sync_reg <= {sync_reg[SYNC_STAGE-2:0],din};
  end
  assign dout = sync_reg[SYNC_STAGE-1];
  
endmodule
// gray-code synchronizer using Data-Sync
module gray_sync #(
  parameter DATA_WIDTH = 4,
  parameter SYNC_STAGE = 3
) (
  input  logic clk,
  input  logic [DATA_WIDTH-1:0] din,
  output logic [DATA_WIDTH-1:0] dout
);
  
  generate for(genvar i=0; i<DATA_WIDTH; i++) begin : gen_sync
    data_sync #(
      .SYNC_STAGE (SYNC_STAGE)
    ) data_sync (
      .clk  (clk), 
      .din  (din[i]),
      .dout (dout[i])
    );
  end endgenerate
  
endmodule
// Data-Sync-pulsegen : synchronize singl-pulse from source_clk to destination_clk
module data_sync_pulsegen #(
  parameter SYNC_STAGE = 3
) (
  input  logic aclk,
  input  logic areset,
  input  logic adin, // pulse
  output logic aqualifier,
  input  logic bclk,
  output logic bdout,// pulse
  output logic bqualifier
);
  
  logic bqualifier_d;
  // qualifier signal generation using T-FF
  always_ff @(posedge aclk) begin
    if (areset) begin
      aqualifier <= 1'b0;
    end else begin
      aqualifier <= aqualifier ^ adin;
    end
  end
  // synchronize qualifier from aclk to bclk
  // 3-clock-cycle for a double-flop to get qualifier valid in bclk-domain
  data_sync #(
    .SYNC_STAGE (SYNC_STAGE)
  ) data_sync_qualifier (
    .clk  (bclk),
    .din  (aqualifier),
    .dout (bqualifier)
  );
  // pulse generation for each logic transition
  always_ff @(posedge bclk) begin
    bqualifier_d <= bqualifier;
  end
  assign bdout = bqualifier_d ^ bqualifier;
  
endmodule
