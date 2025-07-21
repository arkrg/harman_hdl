module dualwatch_core (
    input clk,
    input rst,
    input fmt_mode,  // 1: HH.MM, 0: SS.mm
    input stpw_mode,  // 1: stpw 0: wtch
    input calib_mode,
    input btnL,
    input btnR,
    input btnU,
    input btnD,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);
    wire [6:0] msec;
    wire [5:0] sec;
    wire [5:0] min;
    wire [4:0] hour;
    wire btnL_w, btnR_w, btnU_w, btnD_w;
    wire btnL_s, btnR_s, btnU_s, btnD_s;
    wire [23:0] stpw_data, wtch_data;

    assign {btnL_w, btnR_w, btnU_w, btnD_w} = {4{(stpw_mode == 0)}} & {btnL, btnR, btnU, btnD};
    assign {btnL_s, btnR_s, btnU_s, btnD_s} = {4{(stpw_mode == 1)}} & {btnL, btnR, btnU, btnD};
    
    stpw_top U_STPW (
        .clk      (clk),
        .rst      (rst),
        .btnR     (btnR_s),
        .btnL     (btnL_s),
        .stpw_data(stpw_data)
    );

    wtch_top U_WTCH (
        .clk        (clk),
        .rst        (rst),
        .btnR       (btnR_w),
        .btnL       (btnL_w),
        .btnU       (btnU_w),
        .btnD       (btnD_w),
        .fmt_mode   (fmt_mode),
        .calib_mode (calib_mode),
        .calib_right(calib_right),
        .wtch_data  (wtch_data)
    );

    mux_selN #(
        .SEL_WIDTH(1),
        .IN_WIDTH (24)
    ) U_SEL_WATCHMODE (
        .in ({stpw_data, wtch_data}),
        .sel(stpw_mode),
        .out({hour, min, sec, msec})
    );

    digit_scanner U_DGIT_SCAN (
        .clk        (clk),
        .rst        (rst),
        .msec       (msec),
        .sec        (sec),
        .min        (min),
        .hour       (hour),
        .fmt_mode   (fmt_mode),
        .stpw_mode  (stpw_mode),
        .calib_mode (calib_mode),
        .calib_right(calib_right),
        .fnd_com    (fnd_com),
        .fnd_data   (fnd_data)
    );

endmodule
