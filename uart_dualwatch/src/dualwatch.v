module dualwatch (
    input clk,
    input rst,
    input fmt_mode,  // 1: HH.MM, 0: SS.mm
    input stpw_mode,  // 1: stpw 0: wtch
    input calib_mode,
    input btnL,
    input btnR,
    input btnU,
    input btnD,
    output [3:0] led,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);
    wire [6:0] msec;
    wire [5:0] sec;
    wire [5:0] min;
    wire [4:0] hour;
    wire btnL_d, btnR_d, btnU_d, btnD_d;
    wire [23:0] stpw_data, wtch_data;
    reg [3:0] led_reg;

    dualwatch_core U_DW_CORE (
        .clk        (clk),
        .rst        (rst),
        .fmt_mode   (fmt_mode),
        .calib_mode (calib_mode),
        .btnR       (btnR),
        .btnL       (btnL),
        .btnU       (btnU),
        .btnD       (btnD),
        .fnd_com    (fnd_com),
        .stpw_mode  (stpw_mode),
        .fnd_data   (fnd_data)
    );
    //led blinker
    always @(*) begin
        led_reg = 4'b0000;
        case ({
            stpw_mode, fmt_mode
        })
            2'b00: led_reg = 4'b0100;
            2'b01: led_reg = 4'b1000;
            2'b10: led_reg = 4'b0001;
            2'b11: led_reg = 4'b0010;
        endcase
    end
    assign led = led_reg;


endmodule
