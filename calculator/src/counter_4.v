module counter_4(
    input clk,
    input rst,
    output reg [1:0] cnt
);
    always @(posedge clk or posedge rst) begin
        if(rst) cnt <= 0;
        else begin
            cnt <= cnt + 1;
        end
    end
endmodule
