module wtch_top (
    input clk,
    input rst,

    input btnR,
    input btnL,
    input btnU,
    input btnD,
    input fmt_mode,
    input calib_mode,

    output calib_right,
    output [23:0] wtch_data
);
    wire w_btnU = btnU;
    wire [4:0] hour;
    wire [5:0] min;
    wire [5:0] sec;
    wire [6:0] msec;

    assign wtch_data = {hour, min, sec, msec};

    wtch_controller U_WTCH_CTRL (
        .clk        (clk),
        .rst        (rst),
        .btnR       (btnR),
        .btnL       (btnL),
        .btnU       (btnU),
        .btnD       (btnD),
        .calib_mode (calib_mode),
        .run        (run),
        .up         (up),
        .dn         (dn),
        .calib_right(calib_right)
    );

    wtch_datapath U_WTCH_DP (
        .clk        (clk),
        .rst        (rst),
        .run        (run),
        .up         (up),
        .dn         (dn),
        .fmt_mode   (fmt_mode),
        .calib_right(calib_right),
        .msec       (msec),
        .sec        (sec),
        .min        (min),
        .hour       (hour)
    );


endmodule
