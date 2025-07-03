module fa_8b (
    input [7:0] a,
    b,
    output [7:0] so,
    output co
);
  wire crr;
  fa_4b fa_4b[1:0] (
      .a (a),
      .b (b),
      .ci({crr, 1'b0}),
      .so(so),
      .co({co, crr})
  );

endmodule

module fa_4b (
    input ci,
    input [3:0] a,
    b,
    output [3:0] so,
    output co
);

  wire [3:0] crr;
  full_adder fa[3:0] (
      .a (a),
      .b (b),
      .ci({crr[2:0], ci}),
      .s (so),
      .co(crr)
  );
  assign co = crr[3];

endmodule
module full_adder (
    input  a,
    b,
    ci,
    output s,
    co
);
  half_adder ha0 (
      .a(a),
      .b(b),
      .s(s0),
      .c(c0)
  );
  half_adder ha1 (
      .a(s0),
      .b(ci),
      .s(s),
      .c(c1)
  );
  assign co = c0 | c1;
endmodule

module half_adder (
    input  a,
    b,
    output s,
    c
);

  assign s = a ^ b;
  assign c = a & b;

endmodule
