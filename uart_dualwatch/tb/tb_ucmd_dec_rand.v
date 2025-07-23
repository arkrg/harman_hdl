`timescale 1ns / 1ps
module tb_ucmd_dec_rand;

  reg clk, rst, rx;

  wire tx;
  wire [3:0] led;
  wire [3:0] fnd_com;
  wire [7:0] fnd_data;

  reg [7:0] control_chars [0:9];   // r s c R L U D F M C
  reg [7:0] ascii_pool [0:61];     // 
  reg [7:0] ch;
  integer i;
  integer sel, idx;

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
      #5;
      if (tx_byte == "r") begin
        if (dut.U_CMD_DEC.ucmdR) $display("PASS %c", tx_byte);
        else $display("FAIL, input char = %c @%t", tx_byte, $time);
      end else if (tx_byte == "s") begin
        if (dut.U_CMD_DEC.ucmdR) $display("PASS %c", tx_byte);
        else $display("FAIL, input char = %c @%t", tx_byte, $time);
      end else if (tx_byte == "R") begin
        if (dut.U_CMD_DEC.ucmdR) $display("PASS %c", tx_byte);
        else $display("FAIL, input char = %c @%t", tx_byte, $time);
      end else if (tx_byte == "c") begin
        if (dut.U_CMD_DEC.ucmdL) $display("PASS %c", tx_byte);
        else $display("FAIL, input char = %c @%t", tx_byte, $time);
      end else if (tx_byte == "L") begin
        if (dut.U_CMD_DEC.ucmdL) $display("PASS %c", tx_byte);
        else $display("FAIL, input char = %c @%t", tx_byte, $time);
      end else if (tx_byte == "+") begin
        if (dut.U_CMD_DEC.ucmdU) $display("PASS %c", tx_byte);
        else $display("FAIL, input char = %c @%t", tx_byte, $time);
      end else if (tx_byte == "-") begin
        if (dut.U_CMD_DEC.ucmdD) $display("PASS %c", tx_byte);
        else $display("FAIL, input char = %c @%t", tx_byte, $time);
      end else if (tx_byte == "F") begin
        if (dut.U_CMD_DEC.ucmdFMT) $display("PASS %c", tx_byte);
        else $display("FAIL, input char = %c @%t", tx_byte, $time);
      end else if (tx_byte == "M") begin
        if (dut.U_CMD_DEC.ucmdWTCH) $display("PASS %c", tx_byte);
        else $display("FAIL, input char = %c @%t", tx_byte, $time);
      end else if (tx_byte == "C") begin
        if (dut.U_CMD_DEC.ucmdCALIB) $display("PASS %c", tx_byte);
        else $display("FAIL, input char = %c @%t", tx_byte, $time);
      end else begin
        if (dut.U_CMD_DEC.ucmdR | dut.U_CMD_DEC.ucmdL | dut.U_CMD_DEC.ucmdU|dut.U_CMD_DEC.ucmdD|dut.U_CMD_DEC.ucmdFMT|dut.U_CMD_DEC.ucmdWTCH|dut.U_CMD_DEC.ucmdCALIB)
          $display("FAIL, input char = %c @%t", tx_byte, $time);
        else $display("PASS %c", tx_byte);
      end
    end
  endtask
  initial begin
    // 제어 문자 초기화 (r s c R L + - M F C)
    control_chars[0] = "r";
    control_chars[1] = "s";
    control_chars[2] = "c";
    control_chars[3] = "R";
    control_chars[4] = "L";
    control_chars[5] = "+";
    control_chars[6] = "-";
    control_chars[7] = "M";
    control_chars[8] = "F";
    control_chars[9] = "C";

    // ASCII 문자 pool 초기화 (0-9A-Za-z)
    idx = 0;
    for (i = 48; i <= 57; i = i + 1) begin  // '0'-'9'
      ascii_pool[idx] = i[7:0];
      idx = idx + 1;
    end
    for (i = 65; i <= 90; i = i + 1) begin  // 'A'-'Z'
      ascii_pool[idx] = i[7:0];
      idx = idx + 1;
    end
    for (i = 97; i <= 122; i = i + 1) begin  // 'a'-'z'
      ascii_pool[idx] = i[7:0];
      idx = idx + 1;
    end
  end

  initial begin
    rst = 0;
    clk = 0;
    rx  = 1;
    #(1);
    rst = 1;
    #(5);
    rst = 0;

    for (i = 0; i < 100; i = i + 1) begin
      sel = {$random} % 10;
      if (sel < 4) begin
        ch = control_chars[{$random}%10];
      end else begin
        ch = ascii_pool[{$random}%62];
      end
      $display("test %c", ch);
      uart_send_byte(ch);
    end
    $finish;

  end

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars();
  end
endmodule
