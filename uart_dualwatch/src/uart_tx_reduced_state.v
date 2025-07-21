module uart_tx #(
    parameter DATA_WIDTH = 8,
    parameter OSV_RATE   = 16
) (
    input clk,
    input rst,
    input start,
    input b_tick,
    input [7:0] tx_data,
    output tx_busy,
    output tx
);
    localparam STATE_NUM = 5, STATE_WIDTH = $clog2(STATE_NUM);
    localparam [STATE_WIDTH-1:0] IDLE = 0, WAIT = 1, START = 2, DATA = 3, STOP = 4;

    reg [$clog2(OSV_RATE)-1:0] c_tickcnt, n_tickcnt;
    reg [STATE_WIDTH-1:0] c_state, n_state;
    reg [2:0] c_bitcnt, n_bitcnt;
    reg c_tx, n_tx;
    reg c_busy, n_busy;
    reg [7:0] c_data, n_data;

    assign tx_busy = c_busy;
    assign tx = c_tx;

    //FSM
    //state register
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            c_state   <= IDLE;
            c_tx      <= 1;
            c_busy    <= 1;
            c_bitcnt  <= 0;
            c_tickcnt <= 0;
            c_data    <= 0;
        end else begin
            c_state   <= n_state;
            c_tx      <= n_tx;
            c_busy    <= n_busy;
            c_bitcnt  <= n_bitcnt;
            c_tickcnt <= n_tickcnt;
            c_data    <= n_data;
        end
    end
    always @(*) begin
        n_state   = c_state;
        n_tx      = c_tx;
        n_busy    = c_busy;
        n_bitcnt  = c_bitcnt;
        n_tickcnt = c_tickcnt;
        n_data    = c_data;
        case (c_state)
            IDLE: begin
                n_tx     = 1;
                n_busy   = 0;
                n_bitcnt = 0;
                if (start) begin  // n_state is  // when s
                    n_state = WAIT;
                    n_data  = tx_data;
                end
            end
            WAIT: begin
                n_busy = 1;  // busy revised
                if (b_tick) begin
                    n_state = START;
                end
            end
            START: begin
                n_tx = 0;
                if (b_tick) begin
                    if (c_tickcnt == OSV_RATE - 1) begin
                        n_state   = DATA;
                        n_tickcnt = 0;
                    end else n_tickcnt = c_tickcnt + 1;
                end
            end
            DATA: begin
                n_tx = c_data[0];
                if (b_tick) begin
                    if (c_tickcnt == OSV_RATE - 1) begin
                        n_tickcnt = 0;
                        n_data = c_data >> 1;
                        if (c_bitcnt == DATA_WIDTH - 1) begin
                            n_bitcnt = 0;
                            n_state  = STOP;
                        end else begin
                            n_bitcnt = c_bitcnt + 1;
                            n_state  = DATA;
                        end
                    end else begin
                        n_tickcnt = c_tickcnt + 1;
                    end
                end
            end
            STOP: begin
                n_tx = 1;
                if (b_tick) begin
                    if (c_tickcnt == OSV_RATE - 1) begin
                        n_tickcnt = 0;
                        n_state   = IDLE;
                    end else begin
                        n_tickcnt = c_tickcnt + 1;
                    end
                end
            end
        endcase
    end
endmodule

// module uart_tx #(
//     parameter DATA_WIDTH = 8,
//     parameter OSV_RATE   = 16
// ) (
//     input clk,
//     input rst,
//     input start,
//     input b_tick,
//     input [7:0] tx_data,
//     output tx_busy,
//     output tx
// );
//     localparam STATE_NUM = 5, STATE_WIDTH = $clog2(STATE_NUM);
//     localparam [STATE_WIDTH-1:0] IDLE = 0, WAIT = 1, START = 2, DATA = 3, STOP = 4;

//     reg [$clog2(OSV_RATE)-1:0] c_tickcnt, n_tickcnt;
//     reg [STATE_WIDTH-1:0] c_state, n_state;
//     reg [2:0] c_bitcnt, n_bitcnt;
//     reg c_tx, n_tx;
//     reg c_busy, n_busy;
//     reg [7:0] c_data, n_data;

//     assign tx_busy = c_busy;
//     assign tx = c_tx;

//     //FSM
//     //state register
//     always @(posedge clk or posedge rst) begin
//         if (rst) begin
//             c_state   <= IDLE;
//             c_tx      <= 1;
//             c_busy    <= 1;
//             c_bitcnt  <= 0;
//             c_tickcnt <= 0;
//             c_data    <= 0;
//         end else begin
//             c_state   <= n_state;
//             c_tx      <= n_tx;
//             c_busy    <= n_busy;
//             c_bitcnt  <= n_bitcnt;
//             c_tickcnt <= n_tickcnt;
//             c_data    <= n_data;
//         end
//     end
//     always @(*) begin
//         n_state   = c_state;
//         n_tx      = c_tx;
//         n_busy    = c_busy;
//         n_bitcnt  = c_bitcnt;
//         n_tickcnt = c_tickcnt;
//         n_data    = c_data;
//         case (c_state)
//             IDLE: begin
//                 n_tx     = 1;
//                 n_busy   = 0;
//                 n_bitcnt = 0;
//                 if (start) begin  // n_state is 
//                     n_state = WAIT;
//                     n_busy  = 1;  // busy revised
//                     n_data  = tx_data;
//                 end
//             end
//             WAIT: begin
//                 if (b_tick) begin
//                     if (c_tickcnt == OSV_RATE - 1) begin
//                         n_state   = START;
//                         n_tickcnt = 0;
//                     end else begin
//                         n_tickcnt = c_tickcnt + 1;
//                     end
//                 end
//             end
//             START: begin
//                 n_tx = 0;
//                 if (b_tick) begin
//                     if (c_tickcnt == OSV_RATE - 1) begin
//                         n_state   = DATA;
//                         n_tickcnt = 0;
//                     end else n_tickcnt = c_tickcnt + 1;
//                 end
//             end
//             DATA: begin
//                 n_tx = c_data[0];
//                 if (b_tick) begin
//                     if (c_tickcnt == OSV_RATE - 1) begin
//                         n_tickcnt = 0;
//                         if (c_bitcnt == DATA_WIDTH - 1) begin
//                             n_data   = c_data >> 1;
//                             n_bitcnt = 0;
//                             n_state  = STOP;
//                         end else begin
//                             n_bitcnt = c_bitcnt + 1;
//                             n_state  = DATA;
//                         end
//                     end else begin
//                         n_tickcnt = c_tickcnt + 1;
//                     end
//                 end
//             end
//             STOP: begin
//                 n_tx = 1;
//                 if (b_tick) begin
//                     if (c_tickcnt == OSV_RATE - 1) begin
//                         n_state = IDLE;
//                     end else begin
//                         n_tickcnt = c_tickcnt + 1;
//                     end
//                 end
//             end
//         endcase
//     end
// endmodule
