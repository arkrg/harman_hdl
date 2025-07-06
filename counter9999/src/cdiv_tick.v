module cdiv_tick #(
    parameter MAX_COUNTER = 100_000,
    parameter WIDTH = $clog2(MAX_COUNTER)

) (
    input  clk,
    input  rst,
    output pls
);
  reg [WIDTH-1:0] cnt;
  always @(posedge clk or posedge rst) begin
    if (rst) cnt <= 0;
    else if (cnt >= MAX_COUNTER - 1) begin
      cnt <= 0;
    end else cnt <= cnt + 1;
  end
  assign pls = (cnt == MAX_COUNTER - 1);

endmodule
