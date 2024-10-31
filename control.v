module Control(hazard,opcode, reg_dst, jump, branch, mem_read, mem_to_reg, alu_op, mem_write, alu_src, reg_write);

input wire hazard;
input wire [5:0] opcode;
output reg reg_dst;
output reg jump;
output reg branch;
output reg mem_read;
output reg mem_to_reg;
output reg [1:0] alu_op;
output reg mem_write;
output reg alu_src;
output reg reg_write;

always @* begin
    case (hazard)
        1'b1: begin
            reg_dst    <= 0;
            alu_src    <= 0;
            mem_to_reg <= 0;
            reg_write  <= 0;
            mem_read   <= 0;
            mem_write  <= 0;
            branch     <= 0;
            jump       <= 0;
            alu_op     <= 0;
        end
        1'b0: begin
            case (opcode)
                6'b000000 : begin // R-format
                    reg_dst    <= 1;
                    alu_src    <= 0;
                    mem_to_reg <= 0;
                    reg_write  <= 1;
                    mem_read   <= 0;
                    mem_write  <= 0;
                    branch     <= 0;
                    jump       <= 0;
                    alu_op     <= 2;
                end
                6'b100011 : begin // lw
                    reg_dst    <= 0;
                    alu_src    <= 1;
                    mem_to_reg <= 1;
                    reg_write  <= 1;
                    mem_read   <= 1;
                    mem_write  <= 0;
                    branch     <= 0;
                    jump       <= 0;
                    alu_op     <= 0;
                end
                6'b101011 : begin // sw
                    reg_dst    <= 0;
                    alu_src    <= 1;
                    mem_to_reg <= 0;
                    reg_write  <= 0;
                    mem_read   <= 0;
                    mem_write  <= 1;
                    branch     <= 0;
                    jump       <= 0;
                    alu_op     <= 0;
                end
                6'b000100 : begin // beq
                    reg_dst    <= 0;
                    alu_src    <= 0;
                    mem_to_reg <= 0;
                    reg_write  <= 0;
                    mem_read   <= 0;
                    mem_write  <= 0;
                    branch     <= 1;
                    jump       <= 0;
                    alu_op     <= 1;
                end
                6'b001000 : begin // addi
                    reg_dst    <= 0;
                    alu_src    <= 1;
                    mem_to_reg <= 0;
                    reg_write  <= 1;
                    mem_read   <= 0;
                    mem_write  <= 0;
                    branch     <= 0;
                    jump       <= 0;
                    alu_op     <= 3;
                end
                6'b000010 : begin // J-format
                    reg_dst    <= 0;
                    alu_src    <= 0;
                    mem_to_reg <= 0;
                    reg_write  <= 0;
                    mem_read   <= 0;
                    mem_write  <= 0;
                    branch     <= 0;
                    jump       <= 1;
                    alu_op     <= 0;
                end
                default : begin
                    reg_dst    <= 0;
                    alu_src    <= 0;
                    mem_to_reg <= 0;
                    reg_write  <= 0;
                    mem_read   <= 0;
                    mem_write  <= 0;
                    branch     <= 0;
                    jump       <= 0;
                    alu_op     <= 0;
                end
            endcase
        end
    endcase
    
end
endmodule
