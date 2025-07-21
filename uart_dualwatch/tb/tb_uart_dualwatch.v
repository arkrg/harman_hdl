`timescale 1ns / 1ps
module tb_uart_dualwatch ();
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
  uart_watch_top dut (
      .clk     (clk),
      .rst     (rst),
      .sw_fmt  (sw_fmt),    // 1: HH.MM 0: SS.mm
      .sw_wtch (sw_wtch),   // 1: wtch 0: stpw
      .sw_calib(sw_calib),
      .btnR    (btnR),
      .btnL    (btnL),
      .btnU    (btnU),
      .btnD    (btnD),
      .rx      (rx),
      .tx      (tx),
      .led     (led),
      .fnd_com (fnd_com),
      .fnd_data(fnd_data)
  );
  assign rx_done = ~dut.fifo_tx_push;
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
    send_uart(.send_data(send_data));
    @(negedge rx_done);
    $display("***************************UART RX DONE: %t", $time);
    // second try
    // send_uart(.send_data(send_data), .b_tick(dut.b_tick));
    // @(negedge lp_rxdone_txstart);
    // $display("***************************UART RX DONE: %t", $time);
    // @(negedge tx_busy);
    // $display("***************************UART TX DONE: %t", $time);
    $finish;
  end

  task send_uart(input [7:0] send_data);

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
      #(1041662 * 15);  // uart 9600bps bit time;
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
  initial begin
    $dumpfile("wave.vcd");
    $dumpvars();
  end

endmodule
