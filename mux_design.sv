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
