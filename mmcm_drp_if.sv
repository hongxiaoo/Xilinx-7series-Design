module mmcm_drp_if #(
  parameter RSEL_WIDTH = 1,
  parameter REG_CFG_COUNT = 23,
  parameter ADDR_WIDTH = $clog2(REG_CFG_COUNT)
) (
  input  logic clk,
  input  logic reset,
);

endmodule
