module xilinx_jtag_controller (
  output logic clk,
  output logic reset,
  input  logic [7:0] reg_data_i,
  input  logic [3:0] reg_addr_i,
  output logic [7:0] reg_data_o,
  output logic [3:0] reg_addr_o,
  output logic reg_update
);
  
  logic [10:0] reg_shift_data;
  logic tdi,tdo,tck,update,shift;
  
  BSCANE2 #(
    .JTAG_CHAIN(1)
  ) BSCANE2_inst (
    .CAPTURE(capture), // capture output from TAP controller
    .DRCK(clk),        // gated TCK, when SEL is asserted
    .RESET(reset),     // reset output for TAP controller
    .RUNTEST(runtest),
    .SEL(sel),         // user instruction active output
    .SHIFT(shift),     // shift output from TAP controller
    .TCK(tck),         // test clock
    .TDI(tdi),         // test data input
    .TMS(tms),         // test mode select output
    .UPDATE(update),   // update output from TAP controller
    .TDO(tdo)          // test data output
  );
  
  assign reg_update = update & sel;
  assign reg_addr_o = reg_shift_data[2:0];
  assign reg_data_o = reg_shift_data[10:3];
  
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      reg_shift_data <= 11'd0;
    end else if (shift && sel) begin
      reg_shift_data <= {tdi,reg_shift_data[10:1]};
    end else begin
      reg_shift_data <= {reg_data_i,reg_addr_i};
    end
  end
  
  assign tdo = reg_shift_data[0];
  
endmodule
