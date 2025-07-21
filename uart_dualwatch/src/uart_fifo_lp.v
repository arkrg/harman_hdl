module uart_fifo_lp (
    input clk,
    input rst,
    input rx,
    output [7:0] rdata_wdata,
    output fifo_tx_push,
    output tx
);
  wire tx_start, rx_done;
  wire [7:0] tx_data, rx_data;

  // RX UART -> RX FIFO
  wire [7:0] rx_data_wdata;
  wire rx_done_push;
  // RX FIFO -> TX FIFO
  // wire [7:0] rdata_wdata;
  wire empty_bpush;
  // TX FIFO -> RX FIFO
  wire full_bpop;
  // TX FIFO -> TX UART
  wire [7:0] rdata_tx_data;
  wire empty_bstart;
  // TX UART -> TX FIFO
  wire tx_busy_bpop;
  assign fifo_tx_push = ~empty_bpush;

  uart U_UART (
      .clk     (clk),
      .rst     (rst),
      .tx_start(~empty_bstart),
      .rx      (rx),
      .tx      (tx),
      .tx_data (rdata_tx_data),
      .tx_busy (tx_busy_bpop),
      .tx_done (z_tx_done),
      .rx_data (rx_data_wdata),
      .rx_busy (z_rx_busy),
      .rx_done (rx_done_push)
  );
  fifo U_FIFO_RX (
      .clk  (clk),
      .rst  (rst),
      .wdata(rx_data_wdata),
      .push (rx_done_push),
      .pop  (~full_bpop),
      .rdata(rdata_wdata),
      .full (z_full),
      .empty(empty_bpush)
  );
  fifo U_FIFO_TX (
      .clk  (clk),
      .rst  (rst),
      .wdata(rdata_wdata),
      .push (~empty_bpush),
      .pop  (~tx_busy_bpop),
      .rdata(rdata_tx_data),
      .full (full_bpop),
      .empty(empty_bstart)
  );

endmodule
