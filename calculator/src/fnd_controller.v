`timescale 1ns / 1ps
module fnd_ctrl (
    input [1:0] sel_place,
    input  [8:0] sum,
    output reg [7:0] fnd_data
);
    wire [3:0] disit_1, disit_10, disit_100, disit_1000;
    wire [7:0] fnd_data_1, fnd_data_10, fnd_data_100, fnd_data_1000;

    digit_spliter inst_spltr (
        .sum       (sum),
        .digit_1   (disit_1),
        .digit_10  (disit_10),
        .digit_100 (disit_100),
        .digit_1000(disit_1000)
    );

    bcd_decoder inst_dec_1 (
        .bcd(disit_1),
        .fnd_data(fnd_data_1)
    );
    bcd_decoder inst_dec_10 (
        .bcd(disit_10),
        .fnd_data(fnd_data_10)
    );
    bcd_decoder inst_dec_100 (
        .bcd(disit_100),
        .fnd_data(fnd_data_100)
    );
    bcd_decoder inst_dec_1000 (
        .bcd(disit_1000),
        .fnd_data(fnd_data_1000)
    );
    
    always @(*) begin
        fnd_data = 'b0;
        case(sel_place)
            2'b00: fnd_data = fnd_data_1;
            2'b01: fnd_data = fnd_data_10;
            2'b10: fnd_data = fnd_data_100;
            2'b11: fnd_data = fnd_data_1000;
        endcase
    end

endmodule

module digit_spliter (
    input  [8:0] sum,
    output [3:0] digit_1,
    digit_10,
    digit_100,
    digit_1000
);
    assign digit_1 = sum % 10;
    assign digit_10 = sum / 10 % 10;
    assign digit_100 = sum / 100 % 10;
    assign digit_1000 = sum / 1000 % 10;
endmodule

module bcd_decoder (
    input [3:0] bcd,
    output reg [7:0] fnd_data
);

    always @(*) begin
        fnd_data = 8'h0;
        case (bcd)
            0: fnd_data = 8'hc0;
            1: fnd_data = 8'hf9;
            2: fnd_data = 8'ha4;
            3: fnd_data = 8'hb0;
            4: fnd_data = 8'h99;
            5: fnd_data = 8'h92;
            6: fnd_data = 8'h82;
            7: fnd_data = 8'hf8;
            8: fnd_data = 8'h80;
            9: fnd_data = 8'h90;
        endcase
    end

endmodule
