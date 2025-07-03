module clk_div#(
    parameter REF_CNT = 100_000
) (
    input clk,
    input rst,
    output pls
);
    reg [16:0] cnt;
    always @(posedge clk or posedge rst) begin
        if (rst) cnt <= 0;
        else if(cnt >= REF_CNT-1) begin
            cnt <= 0;
        end else cnt <= cnt + 1;
    end
    assign pls = (cnt == REF_CNT-1);

endmodule
