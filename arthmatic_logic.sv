module add_sub #(
  parameter DATA_WIDTH = 8
) (
  input  logic clk,
  input  logic mode, // 0/1 = ADD/SUB
  input  logic [DATA_WIDTH-1:0] a,
  input  logic [DATA_WIDTH-1:0] b,
  output logic [DATA_WIDTH-0:0] sum
);
  
  always_ff @(posedge clk) begin
    sum <= a + ({DATA_WIDTH{mode}}^b) + mode;
  end

endmodule

// 2-stage pipelined MULTIPLIER - uses 1-DSP48
module int_mul #(
  parameter DATA_WIDTH = 8
) (
  input  logic clk,
  input  logic [DATA_WIDTH-1:0] a,
  input  logic [DATA_WIDTH-1:0] b,
  output logic [2*DATA_WIDTH-1:0] mul
);
  
  logic signed [DATA_WIDTH-1:0] a_reg;
  logic signed [DATA_WIDTH-1:0] b_reg;
  always_ff @(posedge clk) begin
    a_reg <= a;
    b_reg <= b;
    mul <= a_reg * b_reg;
  end

endmodule
// 2-stage pipelined load-enabled MAC - uses 1-DSP48
module int_mac #(
  parameter DATA_WIDTH = 8
) (
  input  logic clk,
  input  logic load,
  input  logic [DATA_WIDTH-1:0] a,
  input  logic [DATA_WIDTH-1:0] b,
  output logic [2*DATA_WIDTH-1:0] acc
);
  
  logic signed [DATA_WIDTH-1:0] a_reg;
  logic signed [DATA_WIDTH-1:0] b_reg;
  logic signed [2*DATA_WIDTH-1:0] mul_reg;
  logic signed [2*DATA_WIDTH-1:0] acc_int;
  logic signed [2*DATA_WIDTH-1:0] acc_reg;
  
  assign acc_int = load ? {2*DATA_WIDTH{1'b0}} : acc_reg;
  always_ff @(posedge clk) begin
    a_reg <= a;
    b_reg <= b;
    mul_reg <= a_reg * b_reg;
    acc_reg <= acc_int + mul_reg;
  end
  assign acc = acc_reg;
  
endmodule
