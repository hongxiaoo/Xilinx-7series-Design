module mmcm_drp_if #(
  parameter RSEL_WIDTH = 1,
  parameter CONFIG_COUNT = 23,
  parameter ADDR_WIDTH = $clog2(CONFIG_COUNT)
) (
  input  logic clk,
  input  logic reset,
  output logic [RSEL_WIDTH-1:0] rom_sel,
  output logic [ADDR_WIDTH-1:0] rom_addr,
  input  logic [38:0] rom_data,
  // user-interface
  input  logic [RSEL_WIDTH-1:0] s_baddr,
  input  logic [ADDR_WIDTH-1:0] s_count.
  input  logic                  s_valid,
  output logic                  s_ready,
  // MMCM_ADV/PLL_ADV drp-interface
  output logic [15:0] dout,
  input  logic        drdy,
  input  logic        locked,
  output logic        dwe,
  output logic        den,
  output logic [6:0]  daddr,
  output logic [15:0] din,
  output logic        rst_mmcm
);
  
  typedef enum logic [3:0] {
    WAIT_LOCK,WAIT_SEN,ADDRESS,WAIT_A_DRDY,
    BITMASK,BITSEL,WRITE,WAIT_DRDY
  } state_type;
  state_type state;
  logic [ADDR_WIDTH-1:0] config_count;
  // s_ready logic
  always_ff @(posedge clk) begin
    if (reset) begin
      s_ready <= 1'b0;
    end else if (~s_ready && state == WAIT_LOCK && locked) begin
      s_ready <= 1'b1;
    end else if (s_ready && s_valid) begin
      s_ready <= 1'b0;
    end
  end
  // den drp-interface logic 
  always_ff @(posedge clk) begin
    if (reset) begin
      den <= 1'b0;
    end else if (~den && (state == ADDRESS || state == WRITE)) begin
      den <= 1'b1;
    end else if (den && drdy) begin
      den <= 1'b0;
    end
  end
  // dwe drp-interface logic 
  always_ff @(posedge clk) begin
    if (reset) begin
      dwe <= 1'b0;
    end else if (~dwe && state == WRITE) begin
      dwe <= 1'b1;
    end else if (dwe && drdy) begin
      dwe <= 1'b0;
    end
  end
  // state-machine description
  always_ff @(posedge clk) begin
    if (reset) begin
      state <= WAIT_LOCK;
      config_count <= {ADDR_WIDTH{1'b0}};
      rst_mmcm <= 1'b1;
    end else begin
      case(state)
        // wait for MMCM to assert locked
        WAIT_LOCK : begin
          rst_mmcm <= 1'b0;
          if (locked) begin
            state <= WAIT_SEN;
          end
        end
        WAIT_SEN : begin
          if (s_ready && s_valid) begin
            config_count <= s_count;
            state <= ADDRESS;
          end
        end
        ADDRESS : begin
          rst_mmcm <= 1'b1;
          state <= WAIT_A_DRDY;
        end
        WAIT_A_DRDY : begin
          if (den && drdy) begin
            state <= BITMASK;
          end
        end
        BITMASK : state <= BITSEL;
        BITSEL  : state <= WRITE;
        WRITE   : state <= WAIT_DRDY;
        WAIT_DRDY : begin
          if (den && drdy && |config_count) begin
            state <= ADDRESS;
          end else if (den && drdy) begin
            state <= WAIT_LOCK;
          end
        end
        default : begin
          state <= WAIT_LOCK;
          rst_mmcm <= 1'b1;
        end
      endcase
    end
  end
  
endmodule
