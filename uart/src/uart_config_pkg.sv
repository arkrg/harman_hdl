package uart_config;

  typedef struct packed {
    logic parity_en;
    logic parity_even;
    logic [3:0] data_len;
    logic [1:0] stop_len;  // 0: 1, 1:2
  } uart_config;

  typedef struct packed {
    logic [15:0] tx_clks_per_bit;
    logic [4:0]  rx_clks_per_bit;  // 0: 1, 1:2
  } uart_config_bdgen;

  typedef struct packed {
    logic [4:0] osm;
    logic [3:0] smp_nth;
  } uart_config_rx;

  typedef enum {
    IDLE,
    START,
    DATA,
    PARITY,
    STOP
  } uart_states;

  function automatic calc_parity(input parity_en, input parity_even, input [7:0] data);
    if (parity_en) calc_parity = ^data ^ ~parity_even;
    else calc_parity = 0;
  endfunction

  typedef struct packed {
    logic [3:0] data_len;
    logic [1:0] stop_len;
  } ds_numbit;
  /* function automatic set_len(input [2:0] wsl, input stb);

    if (parity_en) calc_parity = ^data ^ parity_odd;
    else calc_parity = 0;
  endfunction
  */
endpackage
