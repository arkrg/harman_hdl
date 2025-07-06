module counter9999 #(
    parameter DIV_SELPLACE = 10_000,
    parameter DIV_COUNTER  = 10_000_000,
    parameter MAX_COUNTER  = 9999
) (
    input clk,
    input rst,

    input sw0_stp,
    input sw1_clr,
    input sw2_inc,

    output [3:0] fnd_com,
    output [6:0] fnd_data
);

  wire pls_10hz;
  wire [1:0] sel_place;
  reg [$clog2(MAX_COUNTER)-1:0] count;

  cdiv_tick #(
      .MAX_COUNTER(DIV_COUNTER)
  ) inst_plsgen_cnt (
      .clk(clk),
      .rst(rst),
      .pls(pls_10hz)
  );

  // original
  // always @(posedge clk or posedge rst) begin
  //     if (rst) begin
  //         count <= 0;
  //     end else begin
  //         if (pls_10hz) begin
  //             if (count == MAX_COUNTER) count <= 0;
  //             else count <= count + 1;
  //         end
  //     end
  // end


  // 0 to 9999 counting
  always @(posedge clk or posedge rst or posedge sw1_clr) begin
    if (rst || sw1_clr) begin
      count <= 0;
    end else begin
      if (!sw0_stp) begin
        if (pls_10hz) begin
          if (!sw2_inc) begin
            if (count >= MAX_COUNTER) count <= 0;
            else count <= count + 1;
          end else begin
            if (count == 0) count <= MAX_COUNTER;
            else count <= count - 1;
          end
        end
      end
    end
  end

  /*----------------------------------------------------------*/
  fnd_ctrl #(
      .DIV_SELPLACE(DIV_SELPLACE)
  ) inst_fndctrl (
      .clk(clk),
      .rst(rst),
      .in_val(count),
      .sel_place(sel_place),
      .fnd_com(fnd_com),
      .fnd_data(fnd_data)
  );

endmodule
