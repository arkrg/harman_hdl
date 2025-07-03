`timescale 1ns / 1ps
module tb_calc_clk ();
  reg clk, rst;
  reg [7:0] a, b;
  wire [3:0] fnd_com;
  wire [6:0] fnd_data;

  time pls_start, pls_stop;
  real pls_period_us;

  calculator dut (
      .clk     (clk),
      .rst     (rst),
      .a       (a),
      .b       (b),
      .fnd_com (fnd_com),
      .fnd_data(fnd_data)
  );

  integer i;

  initial begin
    @(posedge dut.pls_1khz);
    pls_start = $time;
    @(posedge dut.pls_1khz);
    pls_stop = $time;
    pls_period_us = (pls_stop - pls_start) / 1000_000.0;
  end
  initial begin
    clk <= 0;
    rst <= 0;
    #10 rst <= 1;
    #10 rst <= 0;
    for (i = 0; i < 4; i = i + 1) begin
      a = {$random} % 16;
      b = {$random} % 16;
      #1;
      $display("input values  a: %d, b: %d", a, b);
      $display("reference value: %d, adder result: %d", a + b, dut.sum);
      repeat (4) @(posedge dut.pls_1khz);
    end
    $display("period of pls_1khz: %tus", pls_period_us);
    $finish;
  end
  always #5 clk = ~clk;

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0);
  end
endmodule
