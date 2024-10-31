`include "pc.v"
`include "imem.v"
`include "alu.v"
`include "regfile.v" //check
`include "dmem.v"
`include "alucontrol.v"
`include "control.v"
`include "mux.v"
`include "signextend.v"
`include "shift_left.v"
`include "adder.v"
`include "pipeline.v"
`include "hazardUnit.v"
`include "ifIdReg.v"

module Top(clk);

input wire clk;
wire [31:0]pc_in;
wire [31:0]pc_out;
wire [31:0]pc_next;
wire [31:0]inst;
wire [27:0]jump_address_no_pc;
wire [31:0]jump_address;
wire reg_dst;
wire jump;
wire branch;
wire mem_read;
wire mem_to_reg;
wire [1:0]alu_op;
wire mem_write;
wire alu_src; 
wire reg_write;
wire [4:0]write_reg;
wire [31:0]write_data;
wire [31:0]rs_value;
wire [31:0]rt_value;
wire [31:0]immediate; 
wire [3:0]alu_cont;
wire [31:0]alu_second_in;
wire zero;
wire [31:0]alu_result;
wire [31:0]offsett;
wire [31:0]br_alu_result;
wire  brach_select;
wire [31:0]branch_result;
wire [31:0] read_data;
//new outputs ifid pipeline
wire [31:0] if_reg_out_im;
wire [31:0] if_reg_out_add;
//id/ex
wire id_ex_ctr_wb_memtoreg;
wire id_ex_ctr_wb_regw;
wire id_ex_ctr_mj;
wire id_ex_ctr_mr;
wire id_ex_ctr_mw;
wire id_ex_ctr_ex1;
wire [1:0] id_ex_ctr_ex2;
wire id_ex_ctr_ex3;
wire [31:0]id_ex_ifid;
wire [31:0]id_ex_reg1;
wire [31:0]id_ex_reg2;
wire [31:0]id_ex_sign;
wire [4:0]id_ex_inst20;
wire [4:0]id_ex_inst15;
//mux for id-ex
wire [4:0] mux_exmem_out;
//pipeline ex/mem
wire ex_mem_wb_regw;
wire ex_mem_wb_memtoreg;
wire ex_mem_mj;
wire ex_mem_mr;
wire ex_mem_mw;
wire [31:0]ex_mem_addbran;
wire ex_mem_zero;
wire [31:0]ex_mem_aluresult;
wire [31:0]ex_mem_rt_val;
wire [4:0]ex_mem_mux_exmem;
//pipeline mem
wire mem_wb_wb_regw;
wire mem_wb_wb_memtoreg;
wire [31:0] mem_wb_readdata;
wire [31:0] mem_wb_aluResult;
wire [4:0] mem_wb_muxregdst;
//Hazard 
wire PCWrite;
wire IFIDWrite;
wire flush;

//module PC(clk, write, in, out);
PC pc(clk, PCWrite, pc_in, pc_out); 
Adder pc_adder(pc_out, 4, pc_next);
Imem imem(pc_out,inst);
// if id - change inst for if_reg_out
//ifIdReg #(parameter WIDTH=32) (clk, in, out, hazard);
ifIdReg #(32) if_id_im (clk, inst, if_reg_out_im,IFIDWrite);
ifIdReg #(32) if_id_add (clk, pc_next, if_reg_out_add, IFIDWrite);
//
Shiftleft2 #(26,28) shift_jump(if_reg_out_im[25:0],jump_address_no_pc); 
assign jump_address = {pc_next[31:28],jump_address_no_pc};
//
Control control(flush,if_reg_out_im[31:26],reg_dst, jump, branch, mem_read, mem_to_reg, alu_op, mem_write, alu_src, reg_write);
Mux #(5) mux_write_reg(if_reg_out_im[20:16],if_reg_out_im[15:11],reg_dst, write_reg);
//Add the if-id
RegisterFile regfile(clk, if_reg_out_im[25:21], if_reg_out_im[20:16], mem_wb_muxregdst, write_data, mem_wb_wb_regw, rs_value, rt_value);//yes?
// id/ex
pipeline #(1)id_ex_ctr_wb_regw1(clk,reg_write,id_ex_ctr_wb_regw); //checkk
pipeline #(1)id_ex_ctr_wb_memtoreg1(clk,mem_to_reg,id_ex_ctr_wb_memtoreg); //i changed this to mem to reg from reg_write
pipeline #(1) id_ex_ctr_mj1 (clk,branch,id_ex_ctr_mj);
pipeline #(1)id_ex_ctr_mr1 (clk,mem_read,id_ex_ctr_mr);
pipeline #(1) id_ex_ctr_mw1 (clk,mem_write,id_ex_ctr_mw); //double check if this is the input
pipeline #(1)id_ex_ctr_ex1_1(clk, alu_src, id_ex_ctr_ex1);
pipeline #(2) id_ex_ctr_ex2_1(clk, alu_op, id_ex_ctr_ex2);
pipeline #(1) id_ex_ctr_ex3_1(clk, reg_dst, id_ex_ctr_ex3);
pipeline #(32) id_ex_ifid1(clk, if_reg_out_add, id_ex_ifid);
pipeline #(32) id_ex_reg11(clk,rs_value,id_ex_reg1);
pipeline #(32) id_ex_reg21(clk, rt_value, id_ex_reg2);
pipeline #(32) id_ex_sign1(clk, immediate, id_ex_sign);
pipeline #(5) id_ex_inst201(clk,if_reg_out_im[20:16],id_ex_inst20); //changed this one
pipeline #(5) id_ex_inst151(clk, if_reg_out_im[15:11], id_ex_inst15);
Mux #(5)mux_exmem (id_ex_inst20,id_ex_inst15,id_ex_ctr_ex3, mux_exmem_out);
//
Sigextend signedextend(if_reg_out_im[15:0],immediate);
Mux mux_alu_select(id_ex_reg2,id_ex_sign,id_ex_ctr_ex1,alu_second_in);
Alu_control alu_control(id_ex_ctr_ex2, id_ex_sign[5:0], alu_cont); //check if this is actually if_reg_out //changed to id_ex_sign
Alu alu(alu_cont, id_ex_reg1, alu_second_in, alu_result, zero);
Shiftleft2 shift_branch(id_ex_sign,offsett); 
Adder adder_branch(id_ex_ifid,offsett,br_alu_result);
//ex/mem
pipeline #(1) ex_mem_wb_memtoreg1(clk,id_ex_ctr_wb_memtoreg, ex_mem_wb_memtoreg);
pipeline #(1) ex_mem_wb_regw1(clk,id_ex_ctr_wb_regw, ex_mem_wb_regw);
pipeline #(1) ex_mem_mj1 (clk,id_ex_ctr_mj, ex_mem_mj);
pipeline #(1)ex_mem_mr1 (clk,id_ex_ctr_mr, ex_mem_mr);
pipeline #(1) ex_mem_mw1 (clk,id_ex_ctr_mw, ex_mem_mw);
pipeline #(32) ex_mem_addbran1 (clk,br_alu_result,ex_mem_addbran);
pipeline #(1)ex_mem_zero1 (clk,zero, ex_mem_zero);
pipeline #(32) ex_mem_aluresult1 (clk, alu_result, ex_mem_aluresult);
pipeline #(32) ex_mem_rt_val1 (clk,id_ex_reg2,ex_mem_rt_val);
pipeline #(5) ex_mem_mux_exmem1 (clk, mux_exmem_out, ex_mem_mux_exmem);
assign branch_select = ex_mem_mj & ex_mem_zero; //check if branch is supposed to be replaced by ex_mem_m
Mux mux_branch(pc_next,ex_mem_addbran,branch_select,branch_result);
Mux mux_jump_or_branch(branch_result,jump_address,jump,pc_in); //solve this one
Dmem data_mem(clk, ex_mem_aluresult,ex_mem_rt_val, ex_mem_mr, ex_mem_mw, read_data);
//pipeline mem/wb
pipeline #(1) mem_wb_wb_regw1 (clk,ex_mem_wb_regw,mem_wb_wb_regw);
pipeline #(1) mem_wb_wb_memtoreg1 (clk,ex_mem_wb_memtoreg, mem_wb_wb_memtoreg);
pipeline #(32) mem_wb_readdata1 (clk,read_data,mem_wb_readdata);
pipeline #(32) mem_wb_aluResult1 (clk,ex_mem_aluresult,mem_wb_aluResult);
pipeline #(5) mem_wb_muxregdst1 (clk,ex_mem_mux_exmem,mem_wb_muxregdst);
Mux mux_dmem(mem_wb_aluResult,mem_wb_readdata,mem_wb_wb_memtoreg,write_data);
//module hazardUnit (reg_write_mw,reg_write_xm,rd_register_mw, rd_register_xm, rs_register_fd, rt_register_fd, PCWrite, IFIDWrite, mux_flush);
hazardUnit hazardUnit1 (ex_mem_wb_regw, id_ex_ctr_wb_regw, ex_mem_mux_exmem,mux_exmem_out,if_reg_out_im[25:21], if_reg_out_im[20:16],PCWrite,IFIDWrite, flush);
endmodule
