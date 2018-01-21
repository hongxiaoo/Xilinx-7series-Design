// Synthesisable code for IEEE754 SP-floating point arithmatic using DSP48 blocks 
// Single-precision Floating Point[IEEE754] Multipler
module floating_point_multipler (
  input  logic clk,
  input  logic [31:0] a,
  input  logic [31:0] b,
  output logic [31:0] p
);
  
  typedef struct packed {
    logic s;        // sign
    logic [7:0] e;  // exponent
    logic [22:0] m; // mantissa
  } sp_fp_in;
  typedef struct packed {
    logic s;        // sign
    logic [7:0] e;  // exponent
    logic [23:0] m; // mantissa
  } sp_fp_reg;
  sp_fp_in a_in,b_in;
  sp_fp_reg a_r0,b_r0;
  
  assign a_in = a;
  assign b_in = b;
  // pipeline-stage 1 registering i/p
  always_ff @(posedge clk) begin
    a_r0 <= {a_in.s,a_in.e,1'b1,a_in.m};
    b_r0 <= {b_in.s,b_in.e,1'b1,b_in.m};
  end
  
  logic p0_s;
  logic [8:0] p0_e;
  logic [47:0] p0_m;
  // pipeline-stage 2 mul-mantissa using 2-DSP48, add-exponent
  always_ff @(posedge clk) begin
    p0_s <= a_r0.s ^ b_r0.s;
    p0_e <= a_r0.e + b_r0.e - 8'd127;
    p0_m <= a_r0.m * b_r0.m;
  end
  
  logic p1_s;
  logic [8:0] p1_e;
  logic [22:0] p1_m;
  logic g,r,s;
  // pipeline-stage 3 Normalize
  always_ff @(posedge clk) begin
    p1_s <= p0_s;
    p1_e <= p0_e + p0_m[47];
    p1_m <= p0_m[47] ? p0_m[46:24] : p0_m[45:23];
    g <= p0_m[24];    // guard
    r <= p0_m[23];    // round
    s <= |p0_m[22:0]; // sticky
  end
  
  logic p2_s;
  logic [8:0] p2_e;
  logic [22:0] p2_m;
  logic [23:0] p2_m_int;
  assign p2_m_int = p1_m + (r&(g|s));
  // pipeline-stage 3 Round-off
  always_ff @(posedge clk) begin
    p2_s <= p1_s;
    p2_e <= p1_e + (&p1_m);
    p2_m <= (&p1_m) ? p2_m_int[23:1] : p2_m_int[22:0];
  end
  assign p = {p2_s,p2_e[7:0],p2_m[22:0]};
  
endmodule
