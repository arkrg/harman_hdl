`timescale 1ns / 1ps
module digit_scanner #(
    parameter DIV_SELDIGIT = 10_000
) (
    input clk,
    input rst,
    input fmt_mode,
    input stpw_mode,
    input calib_mode,
    input calib_right,
    input  [6:0] msec,
    input  [5:0] sec,
    input  [5:0] min,
    input  [4:0] hour,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);
    wire tik_10khz;
    wire [2:0] sel_digit;
    wire [3:0] digit_msec_1, digit_msec_10;
    wire [3:0] digit_sec_1, digit_sec_10;
    wire [3:0] digit_min_1, digit_min_10;
    wire [3:0] digit_hour_1, digit_hour_10;
    wire [3:0] digit_sec_msec, digit_hour_min;
    wire [3:0] digit_dp_10;
    wire [3:0] digit;
    reg [3:0] pre_fndcom;
    wire dot_onoff;

    digit_spliter #(
        .IN_WIDTH(7)
    ) U_SPLTR_MSEC (
        .i_data  (msec),
        .digit_1 (digit_msec_1),
        .digit_10(digit_msec_10)
    );
    digit_spliter #(
        .IN_WIDTH(6)
    ) U_SPLTR_SEC (
        .i_data  (sec),
        .digit_1 (digit_sec_1),
        .digit_10(digit_sec_10)
    );
    digit_spliter #(
        .IN_WIDTH(6)
    ) U_SPLTR_MIN (
        .i_data  (min),
        .digit_1 (digit_min_1),
        .digit_10(digit_min_10)
    );
    digit_spliter #(
        .IN_WIDTH(5)
    ) U_SPLTR_HOUR (
        .i_data  (hour),
        .digit_1 (digit_hour_1),
        .digit_10(digit_hour_10)
    );

    reg [3:0] fnd_com_;
    always @(*) begin
        fnd_com_ = 4'b1111;
        case (sel_digit[1:0])
            2'b00: fnd_com_ = 4'b1110;
            2'b01: fnd_com_ = 4'b1101;
            2'b10: fnd_com_ = 4'b1011;
            2'b11: fnd_com_ = 4'b0111;
        endcase
    end
    assign fnd_com = fnd_com_;
    dot_comp U_DOTCOMP (
        .msec(msec),
        .dot_onoff(dot_onoff)
    );
    mux_selN #(
        .SEL_WIDTH(3)
    ) U_MUX_8x1_SEC_MSEC (
        .in({
            4'he,
            {3'b111, dot_onoff},
            4'he,
            4'he,
            digit_sec_10,
            digit_sec_1,
            digit_msec_10,
            digit_msec_1
        }),
        .out(digit_sec_msec),
        .sel(sel_digit)
    );
    mux_selN #(
        .SEL_WIDTH(3)
    ) U_MUX_8x1_HOUR_MIN (
        .in({
            4'he,
            {3'b111, dot_onoff},
            4'he,
            4'he,
            digit_hour_10,
            digit_hour_1,
            digit_min_10,
            digit_min_1
        }),
        .out(digit_hour_min),
        .sel(sel_digit)
    );
    mux_selN #(
        .SEL_WIDTH(1)
    ) U_MUX_2x1 (
        .in ({digit_hour_min, digit_sec_msec}),
        .out(digit),
        .sel(fmt_mode)
    );

    bcd_decode U_DEC (
        .bcd(digit),
        .fnd_data(fnd_data)
    );

    cdiv_tik #(
        .MAX_COUNTER(DIV_SELDIGIT)
    ) U_TIKGEN_1KHz (
        .clk(clk),
        .rst(rst),
        .clr(1'b0),
        .run(1'b1),
        .tik(tik_10khz)
    );
    cnt_modN #(
        .N(8)
    ) U_SELDIGIT (
        .clk(tik_10khz),
        .rst(rst),
        .cnt(sel_digit)
    );
endmodule
module dot_comp (
    input [6:0] msec,
    output dot_onoff
);
    assign dot_onoff = (msec >= 50) ? 1 : 0;
endmodule

module digit_spliter #(
    parameter IN_WIDTH = 7
) (
    input [IN_WIDTH-1:0] i_data,
    output [3:0] digit_1,
    output [3:0] digit_10
);
    assign digit_1  = i_data % 10;
    assign digit_10 = i_data / 10 % 10;
endmodule

module bcd_decode (
    input [3:0] bcd,
    output reg [7:0] fnd_data
);

    always @(*) begin
        fnd_data = 8'h0;
        case (bcd)
            4'h0: fnd_data = 8'hc0;
            4'h1: fnd_data = 8'hf9;
            4'h2: fnd_data = 8'ha4;
            4'h3: fnd_data = 8'hb0;
            4'h4: fnd_data = 8'h99;
            4'h5: fnd_data = 8'h92;
            4'h6: fnd_data = 8'h82;
            4'h7: fnd_data = 8'hf8;
            4'h8: fnd_data = 8'h80;
            4'h9: fnd_data = 8'h90;
            ////////////////////
            4'he: fnd_data = 8'hff;
            4'hf: fnd_data = 8'h7f;
        endcase
    end

endmodule
