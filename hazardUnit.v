module hazardUnit (reg_write_mw,reg_write_xm,rd_register_mw, rd_register_xm, rs_register_fd, rt_register_fd, PCWrite, IFIDWrite, mux_flush);

input wire reg_write_mw;
input wire reg_write_xm;
input wire [4:0] rd_register_mw;
input wire [4:0] rd_register_xm;
input wire [4:0] rs_register_fd;
input wire [4:0] rt_register_fd;
output wire PCWrite;
output wire IFIDWrite;
output wire mux_flush;

wire hazard_detected;

assign hazard_detected = (reg_write_xm && (rd_register_xm != 0) && (rd_register_xm == rs_register_fd)) ||
                         (reg_write_mw && (rd_register_mw != 0) && (rd_register_mw == rs_register_fd)) ||
                         (reg_write_xm && (rd_register_xm != 0) && (rd_register_xm == rt_register_fd)) ||
                         (reg_write_mw && (rd_register_mw != 0) && (rd_register_mw == rt_register_fd));

// Assign PCWrite, IFIDWrite, and mux_flush based on the hazard detection
assign PCWrite   = hazard_detected ? 1'b0 : 1'b1;
assign IFIDWrite = hazard_detected ? 1'b0 : 1'b1;
assign mux_flush = hazard_detected ? 1'b0 : 1'b1;

endmodule