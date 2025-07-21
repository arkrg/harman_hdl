module wtch_controller (
    input clk,
    input rst,

    input calib_mode,
    input btnR,        // run_stop, right_digit
    input btnL,        // left_digit
    input btnU,        // +1 count
    input btnD,        // -1 count

    output run,
    output up,
    output dn,
    output calib_right
);
    localparam STOP = 0, RUN = 1, CALIB = 2, UP = 3, DN = 4;
    localparam RIGHT = 0, LEFT = 1;
    reg [2:0] state_reg, state_nxt;
    reg lrstate_reg, lrstate_nxt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state_reg   <= RUN;
            lrstate_reg <= RIGHT;
        end else begin
            state_reg   <= state_nxt;
            lrstate_reg <= lrstate_nxt;
        end
    end

    always @(*) begin
        state_nxt = RUN;
        case (state_reg)
            STOP: begin
                if (calib_mode) state_nxt = CALIB;
                else state_nxt = (btnR == 1) ? RUN : STOP;
            end
            RUN: state_nxt = (btnR == 1) ? STOP : RUN;
            CALIB: begin
                if (!calib_mode) state_nxt = STOP;
                else begin
                    if (btnU == 1) state_nxt = UP;
                    else if (btnD == 1) state_nxt = DN;
                    else state_nxt = CALIB;
                end
            end
            UP:  state_nxt = CALIB;
            DN:  state_nxt = CALIB;
        endcase
    end

    always @(*) begin
        lrstate_nxt = RIGHT;
        case (lrstate_reg)
            RIGHT: lrstate_nxt = (btnL == 1) ? LEFT : RIGHT;
            LEFT:  lrstate_nxt = (btnR == 1) ? RIGHT : LEFT;
        endcase
    end
    assign run = (state_reg == RUN) ? 1 : 0;
    assign up = (state_reg == UP) ? 1 : 0;
    assign dn = (state_reg == DN) ? 1 : 0;
    assign calib_right = (lrstate_reg == RIGHT) ? 1 : 0;

endmodule
