module wtch_datapath #(
    parameter DIV_MSEC = 1_000_000
) (
    input clk,
    input rst,
    input run,
    input dn,
    input up,
    input fmt_mode,
    input calib_right,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour

);
    wire en_hour_ud, en_min_ud, en_sec_ud, en_msec_ud;
    assign en_hour_ud = (fmt_mode == 1) && (calib_right == 0);
    assign en_min_ud  = (fmt_mode == 1) && (calib_right == 1);
    assign en_sec_ud  = (fmt_mode == 0) && (calib_right == 0);
    assign en_msec_ud = (fmt_mode == 0) && (calib_right == 1);


    //note that system clock frequence : 100MHz
    wire w_tick_100hz;
    wire w_tick_msec;
    wire w_tick_sec;
    wire w_tick_min;
    wire z_tick_hour;

    cdiv_tik #(
        .MAX_COUNTER(DIV_MSEC)
    ) U_TIKGEN_100Hz (
        .clk(clk),
        .rst(rst),
        .clr(1'b0),
        .run(run),
        .tik(w_tick_100hz)
    );
    // count msec tick
    tik_counter #(
        .MAX_COUNT(100)  // for 
    ) U_MSEC (
        .clk   (clk),
        .rst   (rst),
        .clr   (1'b0),
        .run   (run),
        .up    (up & en_msec_ud),
        .dn    (dn & en_msec_ud),
        .i_tik (w_tick_100hz),
        .o_time(msec),
        .o_tik (w_tick_msec)
    );
    // count sec tick
    tik_counter #(
        .MAX_COUNT(60)  // for 
    ) U_SEC (
        .clk   (clk),
        .rst   (rst),
        .clr   (1'b0),
        .run   (run),
        .up    (up & en_sec_ud),
        .dn    (dn & en_sec_ud),
        .i_tik (w_tick_msec),
        .o_time(sec),
        .o_tik (w_tick_sec)
    );
    // count min tick
    tik_counter #(
        .MAX_COUNT(60)  // for 
    ) U_MIN (
        .clk   (clk),
        .rst   (rst),
        .clr   (1'b0),
        .run   (run),
        .up    (up & en_min_ud),
        .dn    (dn & en_min_ud),
        .i_tik (w_tick_sec),
        .o_time(min),
        .o_tik (w_tick_min)
    );
    // count hour tick
    tik_counter #(
        .INIT_VAL (12),
        .MAX_COUNT(24)   // for 
    ) U_HOUR (
        .clk   (clk),
        .rst   (rst),
        .clr   (1'b0),
        .run   (run),
        .up    (up & en_hour_ud),
        .dn    (dn & en_hour_ud),
        .i_tik (w_tick_min),
        .o_time(hour),
        .o_tik (z_tick_hour)
    );

endmodule
