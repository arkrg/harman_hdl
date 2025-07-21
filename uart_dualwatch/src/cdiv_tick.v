module cdiv_tik #(
    parameter MAX_COUNTER = 100_000,
    parameter WIDTH = $clog2(MAX_COUNTER)

) (
    input  clk,
    input  rst,
    input  clr,
    input  run,
    output tik
);
    reg [WIDTH-1:0] cnt;
    always @(posedge clk or posedge rst) begin
        if (rst) cnt <= 0;
        else begin
            if (run) begin
                if (cnt >= MAX_COUNTER - 1) cnt <= 0;
                else cnt <= cnt + 1;
            end else if (clr) cnt <= 0;
        end
    end

    assign tik = (cnt == MAX_COUNTER - 1);

endmodule
