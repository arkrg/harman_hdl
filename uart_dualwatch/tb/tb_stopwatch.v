`timescale 1ns / 1ps
module tb_stopwatch;
  `define SIM
  reg clk, rst, rx;

  wire tx;
  wire [3:0] led;
  wire [3:0] fnd_com;
  wire [7:0] fnd_data;

  uart_watch_top dut (
      .clk(clk),
      .rst(rst),
      .rx(rx),
      .sw_fmt(0),
      .sw_stpw(0),
      .sw_calib(0),
      .btnR(0),
      .btnL(0),
      .btnU(0),
      .btnD(0),
      .tx(tx),
      .led(led),
      .fnd_com(fnd_com),
      .fnd_data(fnd_data)
  );

  always #5 clk = ~clk;

  task uart_send_byte;
    input [7:0] tx_byte;
    integer i;
    begin
      rx = 0;
      #(104167);
      for (i = 0; i < 8; i = i + 1) begin
        rx = tx_byte[i];
        #(104167);
      end
      rx = 1;
      @(negedge dut.fifo_tx_push);
    end
  endtask

  initial begin
    rst = 0;
    clk = 0;
    rx  = 1;
    #(1);
    rst = 1;
    #(5);
    rst = 0;

    uart_send_byte("M");
    uart_send_byte("r");  //run //stopwatch 모드로 전환
    uart_send_byte("c");  // run일때 클리어 안되는거
    uart_send_byte("r");  //stop
    uart_send_byte("c");  //clear
    uart_send_byte("r");  //run

    $finish;
  end

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars();
  end
endmodule
