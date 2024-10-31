module Imem(address, read_data);

input wire [31:0] address;

output wire [31:0] read_data;

reg [31:0] mem [0:255]; // int mem[256];

integer i;
initial begin
// main: two types of hazards
    mem[0] <= 32'b00100000000010000000000000001010; // addi $t0, $0, 0xA
    mem[1] <= 32'b00100000000010010000000000001000; // addi $t1, $0, 0x8
    mem[2] <= 32'b00000001000010010101000000100101; // or  $t2, $t0, $t1   - 2 hazards
    mem[3] <= 32'b00100000000010010000000000000001; // addi $t1, $0, 1
    mem[4] <= 32'b00000001000010000100000000100000; // add  $t0, $t0, $t0
    mem[5] <= 32'b00000001000010100101100000100101; // or $t3, $t0, $t2     - 1 hazard
                  
    for ( i = 6; i < 256; i += 1) mem[i] = 0;
end

assign read_data = mem[ address[31:2] ];

endmodule
