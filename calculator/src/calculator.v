`timescale 1ns / 1ps
module calculator #(
    parameter REF_CNT = 100_000
) (
    input            clk,
    input            rst,
    input      [7:0] a,
    input      [7:0] b,
    output reg [3:0] fnd_com,
    output     [6:0] fnd_data
);
  wire [7:0] so;
  wire co;
  wire pls_1khz;
  wire [8:0] sum;
  wire [7:0] fnd_data_;
  wire [1:0] sel_place;
  assign fnd_data = fnd_data_[6:0];
  assign sum = {co, so};

  clk_div #(
      .REF_CNT(REF_CNT)
  ) inst_cdiv (
      .clk(clk),
      .rst(rst),
      .pls(pls_1khz)
  );
  counter_4 inst_cnt (
      .clk(pls_1khz),
      .rst(rst),
      .cnt(sel_place)
  );
  fa_8b inst_adder (
      .a (a),
      .b (b),
      .so(so),
      .co(co)
  );
  fnd_ctrl inst_fndctrl (
      .sum(sum),
      .sel_place(sel_place),
      .fnd_data(fnd_data)
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
endmodule
