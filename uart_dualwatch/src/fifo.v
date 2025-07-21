module fifo #(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 4
) (
    input                   clk,
    input                   rst,
    input  [DATA_WIDTH-1:0] wdata,
    input                   push,
    input                   pop,
    output [DATA_WIDTH-1:0] rdata,
    output                  full,
    output                  empty
);
    wire [1:0] waddr, raddr;
    registec_file U_REGFILE (
        .clk  (clk),
        .wdata(wdata),
        .waddr(waddr),
        .raddr(raddr),
        .wc_en(~full & push),
        .rdata(rdata)
    );

    fifo_controller U_FIFOCTRL (
        .clk  (clk),
        .rst  (rst),
        .push (push),
        .pop  (pop),
        .waddr(waddr),
        .raddr(raddr),
        .full (full),
        .empty(empty)
    );

endmodule

module registec_file #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 2
) (
    input clk,
    input [DATA_WIDTH-1:0] wdata,
    input [1:0] waddr,
    input [1:0] raddr,
    input wc_en,
    output [DATA_WIDTH-1:0] rdata
);

    reg [DATA_WIDTH-1:0] mem[0:2**(ADDR_WIDTH)-1];
    assign rdata = mem[raddr];
    always @(posedge clk) begin
        if (wc_en) begin
            mem[waddr] <= wdata;
        end
    end

endmodule


module fifo_controller #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 2
) (
    input clk,
    input rst,
    input push,
    input pop,
    output [ADDR_WIDTH-1:0] waddr,
    output [ADDR_WIDTH-1:0] raddr,
    output full,
    output empty
);
    reg [ADDR_WIDTH-1:0] c_wptr, n_wptr;
    reg [ADDR_WIDTH-1:0] c_rptr, n_rptr;
    reg c_full, n_full;
    reg c_empty, n_empty;

    wire [1:0] push_pop;

    assign push_pop = {push, pop};
    assign waddr = c_wptr;
    assign raddr = c_rptr;
    assign full = c_full;
    assign empty = c_empty;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            c_wptr  <= 0;
            c_rptr  <= 0;
            c_full  <= 0;
            c_empty <= 1;
        end else begin
            c_wptr  <= n_wptr;
            c_rptr  <= n_rptr;
            c_full  <= n_full;
            c_empty <= n_empty;
        end
    end

    always @(*) begin
        n_wptr  = c_wptr;
        n_rptr  = c_rptr;
        n_full  = c_full;
        n_empty = c_empty;
        case (push_pop)
            2'b01: begin
                if (!c_empty) begin
                    n_rptr = c_rptr + 1;
                    n_full = 0;
                    if (c_wptr == n_rptr) begin
                        n_empty = 1;
                    end
                end
            end
            2'b10: begin
                if (!c_full) begin
                    n_wptr  = c_wptr + 1;
                    n_empty = 0;
                    if (n_wptr == c_rptr) begin  // timing check
                        n_full = 1;
                    end
                end
            end
            2'b11: begin
                if (c_empty) begin
                    n_wptr  = c_wptr + 1;
                    n_empty = 0;
                end else if (c_full) begin
                    n_rptr = c_rptr + 1;
                    n_full = 0;
                end else begin
                    n_wptr = c_wptr + 1;
                    n_rptr = c_rptr + 1;
                end
            end
        endcase
    end
endmodule
