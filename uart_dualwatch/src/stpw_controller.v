/*
originally clr_reg(clr_nxt) was used
counldnt figure out the reason so it was switched to assign statement
*/
module stpw_controller (
    input clk,
    input rst,

    input btnR,     // run_stop
    input btnL,     // clear

    output clr,
    output run
);
    localparam STOP = 0, RUN = 1, CLEAR = 2;

    reg [1:0] state_reg, state_nxt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state_reg <= STOP;
        end else begin
            state_reg <= state_nxt;
        end
    end
    
    always @(*) begin
        state_nxt= STOP;
        case (state_reg)
            STOP: state_nxt= (btnR == 1) ? RUN : (btnL == 1) ? CLEAR : STOP;
            RUN:  state_nxt= (btnR == 1) ? STOP : RUN;
            CLEAR: state_nxt = STOP;
        endcase
    end
    
    assign run = (state_reg == RUN) ? 1 : 0;
    assign clr = (state_reg == CLEAR) ? 1 : 0;
endmodule
