module Dmem(clk, address, write_data, mem_read, mem_write, read_data);

input wire clk;
input wire [31:0] address;
input wire [31:0] write_data;
input wire mem_read;
input wire mem_write;

output wire [31:0] read_data;

reg [31:0] mem [0:255]; // int mem[256];

always @(posedge clk) begin
    if ( mem_write ) begin
        mem[address] <= write_data;
    end
end

assign read_data = mem_read ? mem[address] : read_data;

endmodule
