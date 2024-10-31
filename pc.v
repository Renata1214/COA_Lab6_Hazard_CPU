module PC(clk, write, in, out);

input wire clk;
input wire write;
input wire [31:0] in;

output wire [31:0] out;

reg [31:0] pc = 0;

always @(posedge clk) begin
    if (write) pc <= in;
end

assign out = pc;

endmodule
