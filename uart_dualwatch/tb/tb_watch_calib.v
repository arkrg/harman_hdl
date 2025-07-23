`timescale 1ns / 1ps
module tb_watch_calib;
  reg clk = 0;
  reg rst = 0;
  reg rx = 1;

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
    rst = 1;
    #100;
    rst = 0;

    uart_send_byte("r");
    #100;


    // 3. 수정모드 진입
    uart_send_byte("C");
    #100;

    // 4. msec/sec 수정 - up/down/left/right 여러 번
    uart_send_byte("+");  //msec up,down
    #100;
    uart_send_byte("+");
    #100;
    uart_send_byte("-");
    #100;
    uart_send_byte("-");
    #100;
    uart_send_byte("L");  //sec up,down
    #100;
    uart_send_byte("+");
    #100;
    uart_send_byte("+");
    #100;
    uart_send_byte("-");
    #100;
    uart_send_byte("-");
    #100;



    uart_send_byte(
        "F");  // 5. hour/min 수정 이전의 btnL을 눌렀기때문에 현재 hour 위치
    #100;
    uart_send_byte("+");
    #100;  // hour up down
    uart_send_byte("+");
    #100;
    uart_send_byte("-");
    #100;
    uart_send_byte("R");  // min up down
    #100;
    uart_send_byte("+");
    #100;
    uart_send_byte("+");
    #100;
    uart_send_byte("-");
    #100;
    uart_send_byte("C");  // 수정모드에서 나옴
    #100;

    uart_send_byte("r");  // 다시 run
    #100;

    $finish;
  end
  initial begin
    $dumpfile("wave.vcd");
    $dumpvars();
  end
endmodule
