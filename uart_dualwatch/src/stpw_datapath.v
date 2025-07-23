module stpw_datapath #(
`ifdef SIM
    parameter DIV_MSEC = 10
`else
    parameter DIV_MSEC = 1_000_000
`endif
) (
    input clk,
    input rst,
    input clr,
    input run,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour

);
  //note that system clock frequence : 100MHz

  wire w_tik_100hz;
  wire w_tik_msec;
  wire w_tik_sec;
  wire w_tik_min;
  wire z_tik_hour;

  // generate 100hz tik
  cdiv_tik #(
      .MAX_COUNTER(DIV_MSEC)
  ) U_TIKGEN_100Hz (
      .clk(clk),
      .rst(rst),
      .clr(clr),
      .run(run),
      .tik(w_tik_100hz)
  );
  // count msec tik
  tik_counter #(
      .MAX_COUNT(100)  // for 
  ) U_MSEC (
      .clk(clk),
      .rst(rst),
      .clr(clr),
      .run(run),
      .up(1'b0),
      .dn(1'b0),
      .i_tik(w_tik_100hz),
      .o_time(msec),
      .o_tik(w_tik_msec)
  );
  // count sec tik
  tik_counter #(
      .MAX_COUNT(60)  // for 
  ) U_SEC (
      .clk(clk),
      .rst(rst),
      .clr(clr),
      .run(run),
      .up(1'b0),
      .dn(1'b0),
      .i_tik(w_tik_msec),
      .o_time(sec),
      .o_tik(w_tik_sec)
  );
  // count min tik
  tik_counter #(
      .MAX_COUNT(60)  // for 
  ) U_MIN (
      .clk(clk),
      .rst(rst),
      .clr(clr),
      .run(run),
      .up(1'b0),
      .dn(1'b0),
      .i_tik(w_tik_sec),
      .o_time(min),
      .o_tik(w_tik_min)
  );
  // count hour tik
  tik_counter #(
      .MAX_COUNT(24)  // for 
  ) U_HOUR (
      .clk(clk),
      .rst(rst),
      .clr(clr),
      .run(run),
      .up(1'b0),
      .dn(1'b0),
      .i_tik(w_tik_min),
      .o_time(hour),
      .o_tik(z_tik_hour)
  );

endmodule
