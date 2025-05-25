module uart #(
) (
    input uart_config ucfg,
    input uart_config_rx ucfg_rx,
    input uart_config_bdgen ucfg_bdgen,

    input rstn,
    input clk,

    input [7:0] data,
    output uart_txd,
    input valid_tx,

    output empty_tsr,
    output busy_tx,

    output [7:0] rsr,
    input uart_rxd,
    output valid_rx,

    output empty_rsr,
    output busy_rx
);
  logic pls_rx, pls_tx;
  logic en_rxcnt;

  uart_tx inst_tx (.*);
  uart_rx inst_rx (.*);
  uart_bdgen inst_bdgen (.*);

endmodule
