module uart_rx #(
) (
    input rstn,
    input clk,
    input pls_rx,
    input uart_rxd,

    input uart_config ucfg,
    input uart_config_rx ucfg_rx,

    output logic [7:0] rsr,
    output logic valid_rx,
    output logic en_rxcnt,
    output logic empty_rsr,
    output logic busy_rx

);
  uart_states state, nxt_state;

  logic [4:0] bitcnt, nxt_bitcnt;
  logic [4:0] smp_cnt;

  logic edge_start;
  logic en_start_det, en_smp_det;
  logic sig_wrap, pls_wrap;
  logic sig_smp, pls_smp;
  logic sampled_data;
  logic parity_ref, parity_recv;

  assign sig_wrap = smp_cnt == ucfg_rx.osm - 1;
  assign sig_smp = smp_cnt == ucfg_rx.smp_nth - 1;
  assign en_start_det = (state == IDLE);
  assign en_smp_det = ~en_start_det;
  assign ref_parity = calc_parity(
      .parity_en(ucfg.parity_en), .parity_even(ucfg.parity_even), .data(rsr)
  );
  edgeDet inst_edgeDet_start (
      .*,
      .en_det(en_start_det),
      .in(uart_rxd),
      .pls(edge_start)
  );
  edgeDet #(
      .POSEDGE(1)
  ) inst_edgeDet_wrap (
      .*,
      .en_det(en_smp_det),
      .in(sig_wrap),
      .pls(pls_wrap)
  );
  edgeDet #(
      .POSEDGE(1)
  ) inst_edgeDet_smp (
      .*,
      .en_det(en_smp_det),
      .in(sig_smp),
      .pls(pls_smp)
  );
  // sampling smp_cnt
  always @(posedge clk or negedge rstn) begin
    if (!rstn) smp_cnt <= 0;
    else begin
      if (pls_rx) begin
        if (sig_wrap) begin
          smp_cnt <= 0;
        end else begin
          smp_cnt <= smp_cnt + 1;

        end
      end
    end
  end

  // sampling buffer
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      sampled_data <= 0;
    end else begin
      if (pls_smp) sampled_data <= uart_rxd;
    end
  end
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      state  <= IDLE;
      bitcnt <= 0;
    end else begin
      if (state == IDLE) begin
        state <= nxt_state;
      end else if (pls_wrap) begin
        bitcnt <= nxt_bitcnt;
        state  <= nxt_state;
      end
    end
  end
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      rsr <= 0;
    end else begin
      if ((state == DATA) && (pls_smp == 1)) begin
        rsr[bitcnt] <= uart_rxd;
      end
      if ((state == PARITY) && (pls_smp == 1)) begin
        parity_recv <= uart_rxd;
      end
    end
  end
  always @(*) begin
    nxt_bitcnt = bitcnt;
    nxt_state  = IDLE;
    case (state)
      IDLE: begin
        nxt_state = edge_start ? START : IDLE;
      end
      START: begin
        nxt_state = (sampled_data == 0) ? DATA : START;
      end
      DATA: begin
        if (bitcnt >= ucfg.data_len - 1) begin
          nxt_state = (ucfg.parity_en) ? PARITY : STOP;
        end else begin
          nxt_bitcnt = bitcnt + 1;
          nxt_state  = DATA;
        end
      end
      PARITY: begin
        nxt_state = STOP;
      end
      STOP: begin
        if (bitcnt >= ucfg.stop_len - 1) begin
          nxt_state = IDLE;
        end else begin
          nxt_state  = STOP;
          nxt_bitcnt = bitcnt + 1;
        end
      end
    endcase
  end
  assign en_rxcnt = state != IDLE;
  assign valid_rx = state == STOP;  // might be modified

endmodule

