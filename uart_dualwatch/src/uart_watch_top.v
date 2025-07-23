module uart_watch_top (
    input        clk,
    input        rst,
    input        sw_fmt,    // 1: HH.MM, 0: SS.mm
    input        sw_stpw,   // 1: stpw 0: watch
    input        sw_calib,
    input        btnR,
    input        btnL,
    input        btnU,
    input        btnD,
    input        rx,
    output       tx,
    output [3:0] led,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);
  localparam [7:0] CMD_RUN = 8'h72, CMD_STOP = 8'h73, CMD_CLEAR = 8'h63, CMD_LEFT = 8'h4C, CMD_RIGHT = 8'h52, CMD_UP = 8'h2B, CMD_DOWN = 8'h2D;
  // ASCII           r : 8'h72,            s : 8'h73,         c : 8'h63,        L : 8'h4C,         R : 8'h52,      + : 8'h2B,        - : 8'h2D
  localparam [7:0] CMD_FMT = 8'h46, CMD_WTCH = 8'h4d, CMD_CALIB = 8'h43;
  // ASCII           F : 8'h72,            M : 8'h73,         C : 8'h63  

  wire tx_start, rx_done;
  wire [7:0] tx_data, rx_data;

  // RX FIFO -> TX FIFO
  wire [7:0] rdata_wdata;
  wire empty_bpush;

  wire cmdR, cmdL, cmdU, cmdD;
  wire bcmdR, bcmdL, bcmdU, bcmdD;
  wire ucmdR, ucmdL, ucmdU, ucmdD;
  wire ucmdFMT, ucmdWTCH, ucmdCALIB;

  sync_deb U_RUN_BTN_DB[3:0] (
      .clk  (clk),
      .rst  (rst),
      .i_btn({btnR, btnL, btnU, btnD}),
      .o_btn({bcmdR, bcmdL, bcmdU, bcmdD})
  );

  uart_fifo_lp U_UART_LP (
      .clk(clk),
      .rst(rst),
      .rx(rx),
      .tx(tx),
      .rdata_wdata(rdata_wdata),
      .empty_bpush(empty_bpush)
  );


  wire fifo_tx_push;
  assign fifo_tx_push = ~empty_bpush;
  wire [7:0] uart_command;
  shift_register U_SR (
      .clk(clk),
      .rst(rst),
      .d  (rdata_wdata),
      .en (fifo_tx_push),
      .q  (uart_command)
  );

  ucmd_decoder U_CMD_DEC (
      .clk         (clk),
      .rst         (rst),
      .sw_fmt      (sw_fmt),
      .sw_stpw     (sw_stpw),
      .sw_calib    (sw_calib),
      .bcmdR       (bcmdR),
      .bcmdL       (bcmdL),
      .bcmdU       (bcmdU),
      .bcmdD       (bcmdD),
      .uart_command(uart_command),
      .fmt_mode    (fmt_mode),
      .stpw_mode   (stpw_mode),
      .calib_mode  (calib_mode),
      .cmdR        (cmdR),
      .cmdL        (cmdL),
      .cmdU        (cmdU),
      .cmdD        (cmdD)
  );
  dualwatch U_DUALWATCH (
      .clk       (clk),
      .rst       (rst),
      .fmt_mode  (fmt_mode),
      .stpw_mode (stpw_mode),
      .calib_mode(calib_mode),
      .btnR      (cmdR),
      .btnL      (cmdL),
      .btnU      (cmdU),
      .btnD      (cmdD),
      .led       (led),
      .fnd_com   (fnd_com),
      .fnd_data  (fnd_data)
  );

endmodule

module shift_register (
    input clk,
    input rst,
    input [7:0] d,
    input en,
    output [7:0] q
);

  reg [7:0] r_q;
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      r_q <= 0;
    end else begin
      if (en) r_q <= d;
      else r_q <= 0;
    end
  end

  assign q = r_q;

endmodule
