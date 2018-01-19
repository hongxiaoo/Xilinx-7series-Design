// pipeline register using SRL32/SRL16 of SLICEM
module pipeline_reg #(
  parameter SYNC_STAGE = 32
) (
  input  logic clk,
  input  logic din,
  output logic dout
);

  logic [SYNC_STAGE-1:0] data;
  always_ff @(posedge clk) begin
    data <= {data[SYNC_STAGE-2:0],din};
  end
  assign dout = data[SYNC_STAGE-1];
  
endmodule
