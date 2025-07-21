module uart_loopback (
    input  clk,
    input  rst,
    input  rx,
    output tx
);


    wire lp_rxdone_txstart;
    wire [7:0] lp_data;
    uart dut (
        .clk     (clk),
        .rst     (rst),
        .tx_start(lp_rxdone_txstart),
        .rx      (rx),
        .tx      (tx),
        .tx_data (lp_data),
        .tx_busy (tx_busy),
        .tx_done (tx_done),
        .rx_data (lp_data),
        .rx_busy (rx_busy),
        .rx_done (lp_rxdone_txstart)
    );


endmodule
