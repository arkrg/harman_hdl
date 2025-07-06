`timescale 1ns / 1ps
module fnd_ctrl (
    input [1:0] sel_place,
    input [13:0] in_val,
    output reg [7:0] fnd_data
);
  wire [3:0] digit_1, digit_10, digit_100, digit_1000;
  wire [7:0] fnd_data_1, fnd_data_10, fnd_data_100, fnd_data_1000;

  digit_spliter inst_spltr (
      .in_val    (in_val),
      .digit_1   (digit_1),
      .digit_10  (digit_10),
      .digit_100 (digit_100),
      .digit_1000(digit_1000)
  );

  bcd_decoder inst_dec_1 (
      .bcd(digit_1),
      .fnd_data(fnd_data_1)
  );
  bcd_decoder inst_dec_10 (
      .bcd(digit_10),
      .fnd_data(fnd_data_10)
  );
  bcd_decoder inst_dec_100 (
      .bcd(digit_100),
      .fnd_data(fnd_data_100)
  );
  bcd_decoder inst_dec_1000 (
      .bcd(digit_1000),
      .fnd_data(fnd_data_1000)
  );

  always @(*) begin
    fnd_data = 'b0;
    case (sel_place)
      2'b00: fnd_data = fnd_data_1;
      2'b01: fnd_data = fnd_data_10;
      2'b10: fnd_data = fnd_data_100;
      2'b11: fnd_data = fnd_data_1000;
    endcase
  end

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
