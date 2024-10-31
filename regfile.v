module RegisterFile(clk, rs_address, rt_address, rd_address, rd_value, reg_write, rs_value, rt_value);

input wire clk;
input wire [4:0] rs_address;
input wire [4:0] rt_address;
input wire [4:0] rd_address;
input wire [31:0] rd_value;
input wire reg_write;

output wire [31:0] rs_value;
output wire [31:0] rt_value;

reg [31:0] mem [0:31];

initial begin
    mem[0] <= 0;
end

always @(negedge clk) begin
    if ( reg_write && rd_address ) begin
        mem[rd_address] <= rd_value;
    end
end

assign rs_value = mem[rs_address];
assign rt_value = mem[rt_address];

endmodule
