import uart_config::*;
module tb_uart_core #() ();
  logic rstn, clk;
  logic pls_tx, valid_tx, uart_txd, empty_tsr, busy_tx;
  logic [7:0] data;

  logic uart_rxd, valid_rx, empty_rsr, busy_rx;
  logic [7:0] rsr;

  logic en_rxcnt, pls_rx;

  logic uart_trxd;

  uart_config ucfg;
  uart_config_rx ucfg_rx;
  uart_config_bdgen ucfg_bdgen;

  assign ucfg.parity_en = 1;
  assign ucfg.parity_even = 1;
  assign ucfg.data_len = 8;
  assign ucfg.stop_len = 2;

  assign ucfg_rx.osm = 16;
  assign ucfg_rx.smp_nth = 8;

  assign ucfg_bdgen.tx_clks_per_bit = 32;
  assign ucfg_bdgen.rx_clks_per_bit = 2;

  assign valid_tx = 1;

  uart_core dut (
      .*,
      .uart_txd(uart_trxd),
      .uart_rxd(uart_trxd)
  );
  /*
  initial begin
    pls_tx <= 0;
    repeat (10) @(posedge clk);
    while (1) begin
      pls_tx <= 1;
      #2 pls_tx <= 0;
      #8;
    end

*/
  initial begin
    clk  <= 0;
    rstn <= 1;
    repeat (5) @(posedge clk);
    rstn <= 0;
    repeat (5) @(posedge clk);
    rstn <= 1;

    data = 8'h0F;
    fork
      wait (valid_rx);
      repeat (500) @(posedge clk);
    join_any
    $finish;
  end
  initial begin
    $dumpfile("waves.vcd");
    $dumpvars(0);
  end

  always #1 clk <= ~clk;
  /*
  task automatic apb_write(input logic [ADDR_WIDTH-1:0] addr, input logic [DATA_WIDTH-1:0] data);
    begin
      @(posedge clk);
      apb.PSEL <= 1;
      apb.PENABLE <= 0;
      apb.PWRITE <= 1;
      apb.PWDATA <= data;
      apb.PADDR <= addr;

      @(posedge clk) apb.PENABLE <= 1;  // enable is assert @ second cycle of apb transfer
      wait (apb.PREADY);

      @(posedge clk) apb.PSEL <= 0;
      apb.PENABLE <= 0;
      apb.PWRITE  <= 0;

    end
  endtask

  task automatic apb_read(input logic [ADDR_WIDTH-1:0] addr, output logic [DATA_WIDTH-1:0] data);
    @(posedge clk);
    apb.PSEL <= 1;
    apb.PENABLE <= 0;
    apb.PWRITE <= 0;
    apb.PADDR <= addr;
    @(posedge clk);
    apb.PENABLE <= 1;

    wait (apb.PREADY);
    data = apb.PRDATA;

    @(posedge clk);
    apb.PSEL <= 0;
    apb.PENABLE <= 0;
    apb.PWRITE <= 0;


  endtask
*/
endmodule
