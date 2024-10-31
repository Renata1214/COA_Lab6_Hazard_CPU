module Shiftleft2
#(
    parameter WIDTH_IN = 32,
    parameter WIDTH_OUT = 32
)
(in, out);

input wire [WIDTH_IN-1:0] in;
output wire [WIDTH_OUT-1:0] out;

assign out = in << 2;

endmodule
