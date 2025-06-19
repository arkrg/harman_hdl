import uart_config::*;
module tb_uart_tx #() ();
  logic rstn, clk;
  logic pls_tx, pls_rx;
  logic vld_tx, uart_txd, empty_tsr, busy_tx;
  logic [7:0] data;

  uart_config_tx ucfg_trx;
  uart_config_bdgen ucfg_bdgen;

  assign ucfg_trx.parity_en = 1;
  assign ucfg_trx.parity_even = 1;
  assign ucfg_trx.data_len = 8;
  assign ucfg_trx.stop_len = 2;

  assign ucfg_bdgen.osm_rate = 2;
  assign ucfg_bdgen.divisor = 2;

  assign vld_tx = 1;


  uart_tx dut_tx (.*);
  uart_bdgen dut_bdgen (.*);

  initial begin
    clk  <= 0;
    rstn <= 1;
    repeat (5) @(posedge clk);
    rstn <= 0;
    repeat (5) @(posedge clk);
    rstn <= 1;

    data = 8'h0F;
    fork
      begin
        wait (dut_tx.done_tx);
        repeat (3) @(posedge clk);
      end
      repeat (200) @(posedge clk);
    join_any

    $finish;
  end
  initial begin
    $dumpfile("waves.vcd");
    $dumpvars(0);
  end

  always #1 clk <= ~clk;
endmodule
