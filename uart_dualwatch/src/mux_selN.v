module mux_selN #(
    parameter SEL_WIDTH = 1,  // select signal's width
    parameter IN_WIDTH  = 4   // input bitwidth
) (
    input [IN_WIDTH*(2**SEL_WIDTH)-1:0] in,
    input [SEL_WIDTH-1:0] sel,
    output [IN_WIDTH-1:0] out
);

    integer i;
    reg [IN_WIDTH-1:0] r_out;
    always @(*) begin
        r_out = in[IN_WIDTH-1:0];
        for (i = 0; i < 2 ** SEL_WIDTH; i = i + 1) begin
            if (sel == i) r_out = in[IN_WIDTH*i+:IN_WIDTH];
        end
    end

    assign out = r_out;

endmodule
