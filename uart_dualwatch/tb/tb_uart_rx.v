`timescale 1ns / 1ps
module tb_uart_rx ();
  parameter ONEBITTIME = 104166;
  reg clk, rst;
  reg rx, tx_start;
  reg [7:0] tx_data;
  wire tx, tx_busy, rx_busy, rx_done;
  wire [7:0] rx_data;

  reg [7:0] recv_data;
  reg [7:0] send_data;

  // loop back
  wire lp_rxdone_txstart;
  wire [7:0] lp_data;
  uart dut (
      .clk     (clk),
      .rst     (rst),
      .tx_start(lp_rxdone_txstart),
      .rx      (rx),
      .tx      (tx),
      .tx_data (lp_data),
      .tx_busy (tx_busy),
      .tx_done (tx_done),
      .rx_data (lp_data),
      .rx_busy (rx_busy),
      .rx_done (lp_rxdone_txstart)
  );
  assign rx_done = lp_rxdone_txstart;
  always #5 clk = ~clk;

  initial begin
    clk <= 0;
    rst <= 1;
    tx_start <= 0;
    rx <= 1;
    tx_data <= 8'h30;
    send_data <= 0;
    recv_data <= 0;

    #10 rst <= 0;

    send_data = 8'h30;
    send_uart(.send_data(send_data), .b_tick(dut.b_tick));
    @(negedge lp_rxdone_txstart);
    $display("***************************UART RX DONE: %t", $time);
    @(negedge tx_busy);
    $display("***************************UART TX DONE: %t", $time);
    // second try
    send_uart(.send_data(send_data), .b_tick(dut.b_tick));
    @(negedge lp_rxdone_txstart);
    $display("***************************UART RX DONE: %t", $time);
    @(negedge tx_busy);
    $display("***************************UART TX DONE: %t", $time);
    $finish;
  end

  task send_uart(input [7:0] send_data, input b_tick);

    integer i;
    begin
      $display(
          "********************************************************************SEND_UART START: %t",
          $time);
      rx <= 0;
      #(104166);  // uart 9600bps bit time;
      for (i = 0; i < 8; i = i + 1) begin
        rx = send_data[i];
        #(104166);  // uart 9600bps bit time;
      end
      rx = 1;  // stop
      // #(104166 / 2);  // uart 9600bps bit time;
      $display(
          "********************************************************************SEND_UART DONE: %t",
          $time);
    end
  endtask


  task recv_uart(input tx, output reg [7:0] recv_data);
    integer i;
    begin
      $display(
          "********************************************************************RECV_UART START: %t",
          $time);
      #(ONEBITTIME);
      #(ONEBITTIME / 2);
      $display(
          "********************************************************************SAMPLE START %t",
          $time);
      for (i = 0; i < 8; i = i + 1) begin
        recv_data[i] <= tx;
        $display(
            "********************************************************************recv_data[%d] = %d @%t",
            i, tx, $time);
        #(ONEBITTIME);  // uart 9600bps bit time;
      end
      #(ONEBITTIME / 2);
      #(ONEBITTIME);
      $display(
          "********************************************************************RECV_UART DONE: %t",
          $time);
    end

  endtask

endmodule
