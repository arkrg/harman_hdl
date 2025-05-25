interface apb_if #(
    parameter ADDR_WIDTH = 32,  // upto 32bits
    parameter DATA_WIDTH = 32   // among 8, 16, 32bits
) (
    input PCLK,
    input PRESETn
);

  logic [  ADDR_WIDTH-1:0] PADDR;
  logic [  DATA_WIDTH-1:0] PWDATA;
  logic [  DATA_WIDTH-1:0] PRDATA;
  logic [DATA_WIDTH/8-1:0] PSTRB;

  logic PNSE, PSEL, PENABLE, PWRITE, PREADY;

  modport requester(
      output PADDR, PSEL, PENABLE, PWRITE, PWDATA, PSTRB,
      input PRDATA, PREADY, PCLK, PRESETn
  );

  modport completer(
      input PADDR, PSEL, PENABLE, PWRITE, PWDATA, PSTRB, PCLK, PRESETn,
      output PRDATA, PREADY

  );

endinterface
