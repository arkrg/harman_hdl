module edgeDet #(
    parameter POSEDGE = 0  // 1 means posedge edge, 0 means negtative edge 
) (
    input  clk,
    input  rstn,
    input  en_det,
    input  in,
    output pls
);
  reg [1:0] buffer;

  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      buffer <= 0;
    end else if (en_det) begin
      buffer <= {buffer[0], in};
    end
  end

  generate
    if (POSEDGE == 1) assign pls = (^buffer) && buffer[0];
    else assign pls = (^buffer) && buffer[1];
  endgenerate

endmodule

