//import uart_config::*;
module uart_bdgen #(
) (
    input rstn,
    input clk,
    input en_rxcnt,

    input uart_config_bdgen ucfg_bdgen,

    output pls_tx,
    output pls_rx
);


  logic [15:0] tx_cnt;
  logic [ 3:0] rx_cnt;

  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      tx_cnt <= 0;
    end else begin
      if (tx_cnt >= ucfg_bdgen.tx_clks_per_bit - 1) begin
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
      if (en_rxcnt) begin
        if (rx_cnt >= ucfg_bdgen.rx_clks_per_bit - 1) begin
          rx_cnt <= 0;
        end else begin
          rx_cnt <= rx_cnt + 1;
        end
      end
    end
  end

  assign pls_rx = (rx_cnt == ucfg_bdgen.rx_clks_per_bit - 1);
  assign pls_tx = (tx_cnt == ucfg_bdgen.tx_clks_per_bit - 1);

endmodule
