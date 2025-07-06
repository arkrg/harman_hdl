`timescale 1ns / 1ps
module fnd_ctrl #(
    parameter DIV_SELPLACE = 10_000
) (
    input clk,
    input rst,
    input [13:0] in_val,
    input [1:0] sel_place,
    output reg [3:0] fnd_com,
    output reg [7:0] fnd_data
);
  wire pls_1khz;
  wire [3:0] digit_1, digit_10, digit_100, digit_1000;
  reg [3:0] digit;

  digit_spliter inst_spltr (
      .in_val    (in_val),
      .digit_1   (digit_1),
      .digit_10  (digit_10),
      .digit_100 (digit_100),
      .digit_1000(digit_1000)
  );

  always @(*) begin
    fnd_com = 4'b1111;
    case (sel_place)
      2'b00: fnd_com = 4'b1110;
      2'b01: fnd_com = 4'b1101;
      2'b10: fnd_com = 4'b1011;
      2'b11: fnd_com = 4'b0111;
    endcase
  end

  always @(*) begin
    digit = 'b0;
    case (sel_place)
      2'b00: digit = digit_1;
      2'b01: digit = digit_10;
      2'b10: digit = digit_100;
      2'b11: digit = digit_1000;
    endcase
  end

  bcd_decoder inst_dec_1 (
      .bcd(digit),
      .fnd_data(fnd_data)
  );
  //-----------
  cdiv_tick #(
      .MAX_COUNTER(DIV_SELPLACE)
  ) inst_plsgen_fnd (
      .clk(clk),
      .rst(rst),
      .pls(pls_1khz)
  );
  cnt_modN #(
      .N(4)
  ) inst_cnt (
      .clk(pls_1khz),
      .rst(rst),
      .cnt(sel_place)
  );

endmodule

module digit_spliter (
    input  [13:0] in_val,
    output [ 3:0] digit_1,
    digit_10,
    digit_100,
    digit_1000
);
  assign digit_1 = in_val % 10;
  assign digit_10 = in_val / 10 % 10;
  assign digit_100 = in_val / 100 % 10;
  assign digit_1000 = in_val / 1000 % 10;
endmodule

module bcd_decoder (
    input [3:0] bcd,
    output reg [7:0] fnd_data
);

  always @(*) begin
    fnd_data = 8'h0;
    case (bcd)
      0: fnd_data = 8'hc0;
      1: fnd_data = 8'hf9;
      2: fnd_data = 8'ha4;
      3: fnd_data = 8'hb0;
      4: fnd_data = 8'h99;
      5: fnd_data = 8'h92;
      6: fnd_data = 8'h82;
      7: fnd_data = 8'hf8;
      8: fnd_data = 8'h80;
      9: fnd_data = 8'h90;
    endcase
  end

endmodule
