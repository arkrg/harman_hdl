`timescale 1ns / 1ps
// Testbench for 'count9999' module
// verufes behavior unter the following countrol signal:
// -sw0_stp: freezes the counter 
// -sw1_clr: resets the counter to zero
// -sw2_inc: determines count direction (0=up, 0=down)

module tb_counter9999 ();
  localparam DIV_SELPLACE = 100;
  localparam DIV_COUNTER = 10_000;

  reg clk, rst;
  reg sw0_stp, sw1_clr, sw2_inc;

  wire [3:0] fnd_com;
  wire [6:0] fnd_data;

  initial begin
    clk <= 0;
    rst <= 0;
    {sw0_stp, sw1_clr, sw2_inc} <= 3'b000;
    //----reset--------------
    #10 rst <= 1;
    //----reset release------
    #10 rst <= 0;
    //----operate for 10 cycles in normal counting mode(up)------
    repeat (10) @(negedge dut.pls_10hz);

    //----hold the counter(no change expected)------
    {sw0_stp, sw1_clr, sw2_inc} <= 3'b100;
    repeat (2) @(negedge dut.pls_10hz);
    {sw0_stp, sw1_clr, sw2_inc} <= 3'b000;
    repeat (5) @(negedge dut.pls_10hz);

    //----clear the counter------
    {sw0_stp, sw1_clr, sw2_inc} <= 3'b010;
    repeat (2) @(negedge dut.pls_10hz);
    {sw0_stp, sw1_clr, sw2_inc} <= 3'b000;
    repeat (5) @(negedge dut.pls_10hz);

    //----count down for 10------
    {sw0_stp, sw1_clr, sw2_inc} <= 3'b001;
    repeat (10) @(negedge dut.pls_10hz);
    {sw0_stp, sw1_clr, sw2_inc} <= 3'b000;
    repeat (5) @(negedge dut.pls_10hz);

    #100 $finish;
  end
  always #5 clk = ~clk;
  counter9999 #(
      .DIV_SELPLACE(DIV_SELPLACE),
      .DIV_COUNTER (DIV_COUNTER)
  ) dut (
      .clk(clk),
      .rst(rst),
      .sw0_stp(sw0_stp),
      .sw1_clr(sw1_clr),
      .sw2_inc(sw2_inc)
  );

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars();
  end
endmodule

