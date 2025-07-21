module btick_generator #(
    `ifdef SIM
        parameter DIVISOR = 100,
    `else 
        parameter DIVISOR = 100_000_000/(9600*16),
    `endif
        parameter WIDTH = $clog2(DIVISOR)
)(
    input clk,
    input rst,
    output b_tick
    );

    reg [WIDTH-1:0] tick_counter;
    reg r_tick;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            tick_counter <= 0;
            r_tick <= 0;
        end
        else begin
            if(tick_counter == DIVISOR-1) begin 
                tick_counter <= 0;
                r_tick <= 1;
            end else begin
                tick_counter <= tick_counter +1;
                r_tick <= 0;
            end
        end
    end

    assign b_tick = r_tick;
endmodule
