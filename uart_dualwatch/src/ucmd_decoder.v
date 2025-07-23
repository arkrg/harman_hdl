module ucmd_decoder(
    input        clk,
    input        rst,
    input        sw_fmt,    // 1: HH.MM, 0: SS.mm
    input        sw_stpw,   // 1: stpw 0: wach
    input        sw_calib,
    input        bcmdR,
    input        bcmdL,
    input        bcmdU,
    input        bcmdD,
    input       [7:0] uart_command,
    output      fmt_mode,
    output      stpw_mode,
    output      calib_mode,
    output      cmdR,
    output      cmdL,
    output      cmdU,
    output      cmdD
    );
    localparam [7:0] CMD_RUN = 8'h72, CMD_STOP = 8'h73, CMD_CLEAR = 8'h63, 
                     CMD_LEFT = 8'h4C, CMD_RIGHT = 8'h52, CMD_UP = 8'h2B, CMD_DOWN = 8'h2D,
                     CMD_FMT = 8'h46, CMD_WTCH = 8'h4d, CMD_CALIB = 8'h43;
    // ASCII           r : 8'h72,            s : 8'h73,         c : 8'h63,        
    //                 L : 8'h4C,            R : 8'h52,         + : 8'h2B,        - : 8'h2D
    //                 F : 8'h72,            M : 8'h73,         C : 8'h63  
    localparam FMT_SSmm = 0, FMT_HHMM = 1, STPW = 0, WTCH = 1, NORM = 0, CALIB = 1;
    reg c_uwtch_state, n_uwtch_state, c_ufmt_state, n_ufmt_state, c_ucalib_state, n_ucalib_state;
    wire ucmdR, ucmdL, ucmdU, ucmdD, ucmdFMT, ucmdWTCH, ucmdCALIB;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            c_ufmt_state   <= FMT_SSmm;
            c_uwtch_state  <= STPW;
            c_ucalib_state <= NORM;
        end else begin
            c_ufmt_state   <= n_ufmt_state;
            c_uwtch_state  <= n_uwtch_state;
            c_ucalib_state <= n_ucalib_state;
        end
    end

    always @(*) begin
        n_ufmt_state = FMT_SSmm;
        if (sw_fmt == 0) begin
            case (c_ufmt_state)
                FMT_HHMM: n_ufmt_state = (ucmdFMT) ? FMT_SSmm : FMT_HHMM;
                FMT_SSmm: n_ufmt_state = (ucmdFMT) ? FMT_HHMM : FMT_SSmm;
            endcase
        end
    end

    assign u_fmt = (c_ufmt_state == FMT_HHMM) ? 1: 0;
    assign fmt_mode = (sw_fmt) ? sw_fmt : u_fmt;

    always @(*) begin
        n_uwtch_state = STPW;
        if (sw_stpw == 0) begin
            case (c_uwtch_state)
                WTCH: n_uwtch_state = (ucmdWTCH) ? STPW : WTCH;
                STPW: n_uwtch_state = (ucmdWTCH) ? WTCH : STPW;
            endcase
        end
    end
    assign u_wtch = (c_uwtch_state == WTCH);
    assign stpw_mode = (sw_stpw) ? sw_stpw : u_wtch;

    always @(*) begin
        n_ucalib_state = NORM;
        if (sw_calib == 0) begin
            case (c_ucalib_state)
                NORM:  n_ucalib_state = (ucmdCALIB) ? CALIB : NORM;
                CALIB: n_ucalib_state = (ucmdCALIB) ? NORM : CALIB;
            endcase
        end
    end
    assign u_calib = (c_ucalib_state == CALIB);
    assign calib_mode = (sw_calib) ? sw_calib : u_calib;

    assign ucmdR = (uart_command == CMD_RUN) | (uart_command == CMD_STOP) | (uart_command == CMD_RIGHT);
    assign ucmdL = (uart_command == CMD_CLEAR) | (uart_command == CMD_LEFT);
    assign ucmdU = (uart_command == CMD_UP);
    assign ucmdD = (uart_command == CMD_DOWN);
    assign ucmdFMT = (uart_command == CMD_FMT);
    assign ucmdWTCH = (uart_command == CMD_WTCH);
    assign ucmdCALIB = (uart_command == CMD_CALIB);

    assign cmdR = (bcmdR) ? bcmdR : ucmdR;
    assign cmdL = (bcmdL) ? bcmdL : ucmdL;
    assign cmdU = (bcmdU) ? bcmdU : ucmdU;
    assign cmdD = (bcmdD) ? bcmdD : ucmdD;

endmodule