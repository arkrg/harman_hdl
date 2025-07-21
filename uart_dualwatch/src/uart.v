module uart (
    input        clk,
    input        rst,
    input        tx_start,
    input  [7:0] tx_data,
    input        rx,
    output       tx,
    output       tx_busy,
    output       tx_done,
    output [7:0] rx_data,
    output       rx_busy,
    output       rx_done
);

    wire b_tick;
    wire w_send;

    btick_generator U_BAUD_TICKGEN (
        .clk   (clk),
        .rst   (rst),
        .b_tick(b_tick)
    );

    uart_tx U_UART_TX (
        .clk    (clk),
        .rst    (rst),
        .start  (tx_start),
        .b_tick (b_tick),
        .tx_data(tx_data),
        .tx_busy(tx_busy),
        .tx     (tx)
    );
    uart_rx U_UART_RX (
        .clk    (clk),
        .rst    (rst),
        .b_tick (b_tick),
        .rx     (rx),
        .rx_data(rx_data),
        .rx_busy(rx_busy),
        .rx_done(rx_done)
    );

endmodule
module ascii_sender #(
    parameter DATADEPTH = 5
) (
    input clk,
    input rst,
    input tx_start,
    input tx_busy,
    output send_tx_start,  // to UART TX, tx_start
    output [7:0] ascii_data
);  // to send seral data

    localparam [1:0] IDLE = 0, SEND = 1;

    reg [$clog2(DATADEPTH)-1:0] send_count;
    reg [7:0] r_ascii_data[0:DATADEPTH-1];
    reg r_send;
    reg state;

    assign ascii_data = r_ascii_data[send_count];
    assign send_tx_start = r_send;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            r_send <= 0;
            send_count <= 0;
            r_ascii_data[0] <= "h";
            r_ascii_data[1] <= "e";
            r_ascii_data[2] <= "l";
            r_ascii_data[3] <= "l";
            r_ascii_data[4] <= "o";
        end else begin
            case (state)
                IDLE: begin
                    send_count <= 0;
                    r_send     <= 1'b0;
                    if (tx_start) begin
                        state  <= SEND;
                        r_send <= 1'b1;
                    end
                end
                SEND: begin
                    r_send <= 1'b0;
                    if (!tx_busy && !r_send) begin
                        send_count <= send_count + 1;
                        r_send <= 1'b1;
                        if (send_count == 3'h4) begin
                            send_count <= 0;
                            state <= IDLE;
                        end else state <= SEND;
                    end
                end
            endcase
        end
    end
endmodule

