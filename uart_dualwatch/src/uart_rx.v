module uart_rx #(
    parameter OVS_RATE   = 16,
    parameter DATA_WIDTH = 8
) (
    input        clk,
    input        rst,
    input        b_tick,
    input        rx,
    output [7:0] rx_data,
    output       rx_busy,
    output       rx_done
);
    localparam [1:0] IDLE = 0, START = 1, DATA = 2, STOP = 3;

    reg [1:0] c_state, n_state;
    reg [3:0] c_tickcnt, n_tickcnt;
    reg [3:0] c_bitcnt, n_bitcnt;
    reg [7:0] c_data, n_data;
    reg c_busy, n_busy;
    reg c_done, n_done;

    assign rx_data = c_data;
    assign rx_busy = c_busy;
    assign rx_done = c_done;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            c_state   <= IDLE;
            c_tickcnt <= 0;
            c_bitcnt  <= 0;
            c_data    <= 0;
            c_busy    <= 0;
            c_done    <= 0;
        end else begin
            c_state   <= n_state;
            c_tickcnt <= n_tickcnt;
            c_bitcnt  <= n_bitcnt;
            c_data    <= n_data;
            c_busy    <= n_busy;
            c_done    <= n_done;
        end
    end

    always @(*) begin
        n_state   = c_state;
        n_tickcnt = c_tickcnt;
        n_bitcnt  = c_bitcnt;
        n_data    = c_data;
        n_busy    = c_busy;
        n_done    = c_done;
        case (c_state)
            IDLE: begin
                n_done = 0;
                if (rx == 0) begin
                    n_state = START;
                    n_busy  = 1;
                end
            end
            START: begin
                if (b_tick) begin
                    if (c_tickcnt == 7) begin
                        n_tickcnt = 0;
                        n_state   = DATA;
                    end else begin
                        n_tickcnt = c_tickcnt + 1;
                    end
                end
            end
            DATA: begin
                if (b_tick) begin
                    if (c_tickcnt == OVS_RATE - 1) begin
                        n_tickcnt = 0;
                        n_data = {
                            rx, c_data[7:1]
                        };  // shift register LSB system
                        if (c_bitcnt == DATA_WIDTH - 1) begin
                            n_state  = STOP;
                            n_bitcnt = 0;
                        end else begin
                            n_bitcnt = c_bitcnt + 1;
                        end
                        n_tickcnt = 0;
                    end else begin
                        n_tickcnt = c_tickcnt + 1;
                    end
                end
            end
            STOP: begin
                if (b_tick) begin
                    if (c_tickcnt == OVS_RATE - 1) begin
                        n_tickcnt = 0;
                        n_state = IDLE;
                        n_tickcnt = 0;
                        n_busy = 0;
                        n_done = 1;
                    end else begin
                        n_tickcnt = c_tickcnt + 1;
                    end
                end
            end
        endcase
    end

endmodule
