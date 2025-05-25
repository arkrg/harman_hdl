module tb_uart_tx #() ();
  logic rstn, clk, pls_tx, valid, uart_txd, empty_tsr, tx_busy;
  logic [7:0] data;

  logic 
  uart_config ucfg;
  uart_config_bdgen ucfg_pls;

  assign ucfg.parity_en = 1;
  assign ucfg.parity_even = 1;
  assign ucfg.data_len = 8;
  assign ucfg.stop_len = 2;

  assign valid = 1;


  uart_tx dut_tx (.*);
  uart_bdgen dut_bdgen (.*, .ucfg(ucfg_pls));

  initial begin
    pls_tx <= 0;
    repeat (10) @(posedge clk);
    while (1) begin
      pls_tx <= 1;
      #2 pls_tx <= 0;
      #8;
    end


  end
  initial begin
    clk  <= 0;
    rstn <= 1;
    repeat (5) @(posedge clk);
    rstn <= 0;
    repeat (5) @(posedge clk);
    rstn <= 1;

    data = 8'h0F;
    fork
      wait (DUT.tx_done);
      repeat (200) @(posedge clk);
    join_any

    /*fork
      begin
        apb_write(.addr(8'h00), .data(32'h000F));
        wait (DUT.fsm_done);
        apb_read(.addr(8'h04), .data(lsr));
        wait (apb.PREADY);
        repeat (2) @(posedge clk);
      end
      repeat (500) @(posedge clk);
    join_any
*/
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
