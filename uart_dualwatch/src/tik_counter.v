module tik_counter #(
    parameter INIT_VAL = 0,
    parameter MAX_COUNT = 100,
    parameter WIDTH = $clog2(MAX_COUNT)
) (
    input              clk,
    input              rst,
    input              clr,
    input              run,
    input              up,
    input              dn,
    input              i_tik,
    output [WIDTH-1:0] o_time,
    output             o_tik
);

    reg [WIDTH-1:0] cnt_reg, cnt_nxt;
    reg tik_reg, tik_nxt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt_reg <= INIT_VAL;
            tik_reg <= 0;
        end else begin
            cnt_reg <= cnt_nxt;
            tik_reg <= tik_nxt;
        end
    end

    always @(*) begin
        cnt_nxt = cnt_reg;
        tik_nxt = 0;
        if (run) begin
            if (i_tik) begin
                if (cnt_reg == MAX_COUNT - 1) begin
                    cnt_nxt = 0;
                    tik_nxt = 1;
                end else begin
                    cnt_nxt = cnt_reg + 1;
                    tik_nxt = 0;
                end
            end
        end else begin
            cnt_nxt = cnt_reg;
            if (clr) cnt_nxt = INIT_VAL;
            if (up) cnt_nxt = (cnt_reg == MAX_COUNT - 1) ? 0 : cnt_reg + 1;
            if (dn) cnt_nxt = (cnt_reg == 0) ? MAX_COUNT - 1 : cnt_reg - 1;
        end
    end

    assign o_tik  = tik_reg;
    assign o_time = cnt_reg;

endmodule
