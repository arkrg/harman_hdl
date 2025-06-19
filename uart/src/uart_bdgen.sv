module uart_bdgen #(
) (
    input rstn,
    input clk,
    //input en_rxcnt,

    input uart_config_bdgen ucfg_bdgen,

    output pls_tx,
    output pls_rx
);
  // divisor = input freq / (desired baudrate * oversampling rate)
  // clks per rx pulse : divisor 
  // clks per tx pulse : divisor * oversampling rate

  logic [11:0] tx_cnt;
  logic [ 7:0] rx_cnt;
  logic [ 7:0] clks_per_pls_tx;
  logic [11:0] clks_per_pls_rx;

  assign clks_per_pls_rx = ucfg_bdgen.divisor - 1;
  assign clks_per_pls_tx = ucfg_bdgen.divisor * ucfg_bdgen.osm_rate - 1;

  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      tx_cnt <= 0;
    end else begin
      if (tx_cnt >= clks_per_pls_tx) begin
        tx_cnt <= 0;
      end else begin
        tx_cnt <= tx_cnt + 1;
      end
    end
  end

  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      rx_cnt <= 0;
    end else begin
      if (rx_cnt >= clks_per_pls_rx) begin
        rx_cnt <= 0;
      end else begin
        rx_cnt <= rx_cnt + 1;
      end
    end
  end

  assign pls_rx = (rx_cnt == clks_per_pls_rx);
  assign pls_tx = (tx_cnt == clks_per_pls_tx);

endmodule
