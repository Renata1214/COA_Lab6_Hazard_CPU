module ifIdReg #(parameter WIDTH=32) (clk, in, out, hazard);

input wire clk;
input wire [WIDTH-1 : 0] in;
input wire hazard;
output reg [WIDTH-1 : 0] out = 0;

//assign IFIDWrite = hazard_detected ? 1'b0 : 1'b1;

always @(posedge clk) begin
    if(hazard) out <= in;
end

endmodule
