//import uart_config::*;
module uart_tx (
    input rstn,
    input clk,
    input pls_tx,
    input [7:0] data,
    input valid_tx,

    input uart_config ucfg,
    //input uart_config_tx ucfg_tx,

    output logic uart_txd,
    output logic empty_tsr,
    output logic busy_tx

);

  uart_states state, nxt_state;

  logic [3:0] bitcnt, nxt_bitcnt;
  logic [7:0] tsr;

  logic load_tsr;
  logic tx_done;
  logic en_start;

  assign tx_busy = (state != IDLE);
  assign en_start = (state == IDLE) && (!empty_tsr);
  assign parity = calc_parity(
      .parity_en(ucfg.parity_en), .parity_even(ucfg.parity_even), .data(tsr)
  );

  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      load_tsr <= 0;
    end else begin
      load_tsr <= (state == IDLE) & valid_tx & empty_tsr;
    end
  end
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      empty_tsr <= 1;
    end else if (load_tsr) begin
      empty_tsr <= 0;
    end else if ((state == STOP) && (nxt_state == IDLE)) begin
      empty_tsr <= 1;
    end
  end
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      tsr <= 0;
    end else begin
      if (load_tsr) begin
        tsr <= data;
      end
      if (tx_done) begin
      end
    end
  end
  always @(posedge clk) begin
    case (state)
      IDLE: uart_txd <= 1;
      START: uart_txd <= 0;
      DATA: uart_txd <= data[bitcnt];
      PARITY: uart_txd <= parity;
      STOP: uart_txd <= 1;
      default: uart_txd <= 1;
    endcase
  end

  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      state  <= IDLE;
      bitcnt <= 0;
    end else begin
      if (pls_tx) begin
        state  <= nxt_state;
        bitcnt <= nxt_bitcnt;
      end
    end
  end

  always @(*) begin
    nxt_state = IDLE;
    nxt_bitcnt = 0;
    tx_done = 0;
    case (state)
      IDLE: begin
        if (en_start) begin
          nxt_state = START;
        end else begin
          nxt_state = IDLE;
        end
      end
      START: begin
        nxt_state = DATA;
      end
      DATA: begin
        if (bitcnt >= ucfg.data_len - 1) begin
          nxt_state = (ucfg.parity_en) ? PARITY : STOP;
        end else begin
          nxt_state  = DATA;
          nxt_bitcnt = bitcnt + 1;
        end
      end
      PARITY: begin
        nxt_state = STOP;
      end
      STOP: begin
        if (bitcnt >= ucfg.stop_len - 1) begin
          nxt_state = IDLE;
          tx_done   = 1;
        end else begin
          nxt_state  = STOP;
          nxt_bitcnt = bitcnt + 1;
        end
      end
    endcase
  end


endmodule
