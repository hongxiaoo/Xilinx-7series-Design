// 4x1 mux can be mapped to a LUT6 (4inputs + 2sel)
module mux4x1 #( 
  parameter DATA_WIDTH = 32
) (
  input  logic [DATA_WIDTH-1:0] din[4],
  input  logic [1:0] sel,
  output logic [DATA_WIDTH-1:0] dout
);

  always_comb begin
    case(sel)
      2'b00 : dout = din[0];
      2'b01 : dout = din[1];
      2'b10 : dout = din[2];
      2'b11 : dout = din[3];
    endcase
  end
  
endmodule
// 8x1 mux uses 2-LUT6 and MUX7
module mux8x1 #( 
  parameter DATA_WIDTH = 32
) (
  input  logic [DATA_WIDTH-1:0] din[8],
  input  logic [2:0] sel,
  output logic [DATA_WIDTH-1:0] dout
);

  logic [DATA_WIDTH-1:0] dout0;
  logic [DATA_WIDTH-1:0] dout1;
  
  mux4x1 #(
    .DATA_WIDTH(DATA_WIDTH)
  ) mux0 (
    .din (din[0:3]),
    .sel (sel[1:0]),
    .dout(dout0)
  );
  mux4x1 #(
    .DATA_WIDTH(DATA_WIDTH)
  ) mux1 (
    .din (din[4:7]),
    .sel (sel[1:0]),
    .dout(dout1)
  );
  assign dout = sel[2] ? dout1 : dout0;
  
endmodule
// 16x1 mux uses 4-LUT6 and MUX7+MUX8
module mux16x1 #( 
  parameter DATA_WIDTH = 32
) (
  input  logic [DATA_WIDTH-1:0] din[15],
  input  logic [3:0] sel,
  output logic [DATA_WIDTH-1:0] dout
);

  logic [DATA_WIDTH-1:0] dout0;
  logic [DATA_WIDTH-1:0] dout1;
  
  mux8x1 #(
    .DATA_WIDTH(DATA_WIDTH)
  ) mux0 (
    .din (din[0:7]),
    .sel (sel[2:0]),
    .dout(dout0)
  );
  mux8x1 #(
    .DATA_WIDTH(DATA_WIDTH)
  ) mux1 (
    .din (din[8:15]),
    .sel (sel[2:0]),
    .dout(dout1)
  );
  assign dout = sel[3] ? dout1 : dout0;
  
endmodule
