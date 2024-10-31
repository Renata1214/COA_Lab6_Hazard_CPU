module Mux
#(parameter WIDTH = 32)
(in1, in2, flag, out);

input wire flag;
input wire [WIDTH-1:0] in1;
input wire [WIDTH-1:0] in2;

output wire [WIDTH-1:0] out;

assign out = flag ? in2 : in1;

endmodule

