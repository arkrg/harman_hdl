module stpw_top (
    input clk,
    input rst,

    input btnR,
    input btnL,

    output [23:0] stpw_data
);

    wire [4:0] hour;
    wire [5:0] min;
    wire [5:0] sec;
    wire [6:0] msec;

    assign stpw_data = {hour, min, sec, msec};

    stpw_controller U_STPW_CTRL (
        .clk      (clk),
        .rst      (rst),
        .btnR     (btnR),
        .btnL     (btnL),
        .clr      (clr),
        .run      (run)
    );

    stpw_datapath U_STPW_DP (
        .clk (clk),
        .rst (rst),
        .clr (clr),
        .run (run),
        .msec(msec),
        .sec (sec),
        .min (min),
        .hour(hour)
    );

endmodule
