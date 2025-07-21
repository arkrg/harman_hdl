module sync_deb #(
    parameter NUM_DFF = 4,
    parameter DIV_DBNC = 100
)(
    input  clk,
    input  rst,
    input  i_btn,
    output o_btn
);

    reg [NUM_DFF-1:0] q_reg, q_nxt;
    reg [$clog2(DIV_DBNC)-1:0] cnt;
    reg deb_reg;
    reg r_db_clk;
    wire debounce;

    // clk divider 1MHz
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            cnt <= 0;
            r_db_clk <= 0;
        end else  begin
            if(cnt == DIV_DBNC-1) begin
                cnt <= 0;
                r_db_clk <= 1;
            end 
            else begin
                 cnt <= cnt+1;
                 r_db_clk <= 0;
            end
        end
    end

    // shift register
    always @(posedge r_db_clk or posedge rst) begin
    //always @(posedge clk or posedge rst) begin
        if (rst) begin
            q_reg <= 0;
        end else begin
            q_reg <= q_nxt;
        end
    end
    
    always @(*) begin
        //q_nxt = {i_btn, q_reg[NUM_DFF-1:1]}; in lecture
        q_nxt = {q_reg[NUM_DFF-2:0],i_btn}; // :D naekkeo
    end
    assign debounce = &q_reg;

    always @(posedge clk or posedge rst) begin
        if(rst) deb_reg <= 0;
        else deb_reg <= debounce;  
    end
    assign o_btn = ~deb_reg & debounce;

endmodule


