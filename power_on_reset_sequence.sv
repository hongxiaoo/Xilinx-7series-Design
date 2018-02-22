module power_on_reset_sequence #(
  parameter int TIMER_VALUE = 128,
  parameter int ASYNC_STAGE = 5,
  parameter int SYNC_STAGE = 2
) (
  input  logic clk,         // slowest-sync-clock
  input  logic async_reset, // async-ext-reset
  input  logic pll_locked,
  output logic [NO_INTERCNCT-1:0] intercnct_reset,
  output logic [NO_PERIFERAL-1:0] periferal_reset,
  output logic [NO_PROCESSOR-1:0] processor_reset,
  output logic sync_reset
);
  
  typedef enum logic [1:0] {IDLE,ACTIVE,DONE} state_type;
  state_type state;
  localparam TIMER_WIDTH = TIMER_VALUE > 128 ? $clog2(TIMER_VALUE) : $clog2(128);
  logic [TIMER_WIDTH-1:0] timer_count;
  // Reset-Sync : Async-assert and sync-deassert
  // Min 3 stage pipeline to mitegate reset recovery and removal time
  // use false_path constraint to Asyn-reg FF/PRE
  reset_sync #(
    .ASYNC_STAGE(ASYNC_STAGE),
    .SYNC_STAGE(SYNC_STAGE)
  ) reset_sync (
    .clk(clk),
    .async_reset(async_reset),
    .sync_reset(sync_reset)
  );
  // interconnect reset register
  always_ff @(posedge clk) begin
    if (sync_reset) begin
      intercnct_reset <= {NO_INTERCNCT{1'b1}};
    end else if (state == ACTIVE && timer_count[6:5] == 2'b01) begin
      intercnct_reset <= {NO_INTERCNCT{1'b0}};
    end
  end
  // periferal reset register
  always_ff @(posedge clk) begin
    if (sync_reset) begin
      periferal_reset <= {NO_PERIFERAL{1'b1}};
    end else if (state == ACTIVE && timer_count[6:5] == 2'b10) begin
      periferal_reset <= {NO_PERIFERAL{1'b0}};
    end
  end
  // processor reset register
  always_ff @(posedge clk) begin
    if (sync_reset) begin
      processor_reset <= {NO_PROCESSOR{1'b1}};
    end else if (state == ACTIVE && timer_count[6:5] == 2'b11) begin
      processor_reset <= {NO_PROCESSOR{1'b0}};
    end
  end
  // state machine to control reset-sequencing
  always_ff @(posedge clk) begin
    if (sync_reset) begin
      state <= IDLE;
      timer_count <= {TIMER_WIDTH{1'b0}};
    end else begin
      case(state)
        IDLE : begin
          if (timer_count >= TIMER_VALUE-1) begin
            state <= ACTIVE;
            timer_count <= {TIMER_WIDTH{1'b0}};
          end else begin
            timer_count <= timer_count + 1'b1;
          end
        end
        ACTIVE : begin
          if (timer_count[6:5] == 2'b11) begin
            state <= DONE;
            timer_count <= {TIMER_WIDTH{1'b0}};
          end else begin
            timer_count <= timer_count + 1'b1;
          end
        end
        DONE : begin
          state <= DONE;
        end
      endcase
    end
  end
  
endmodule
