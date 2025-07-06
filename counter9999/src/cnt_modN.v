/*
    modulo-N up counter
*/
module cnt_modN #(
    parameter N = 4
) (
    input clk,
    input rst,
    output reg [$clog2(N)-1:0] cnt
);
  always @(posedge clk or posedge rst) begin
    if (rst) cnt <= 0;
    else begin
      cnt <= cnt + 1;
    end
  end
endmodule
