`timescale 1ns / 1ps


module RISC_V_Processor_tb();
    reg         clk = 1'b0;
    reg         rst = 1'b0;
    reg         en  = 1'b1;
    wire [31:0] out;
    wire [31:0] instr;
    wire [31:0] register1;
    wire [31:0] register2;
    wire [31:0] PC;
    wire [31:0] imm_J;

RISC_V_Processor Proc ( .CLK(clk), .rst(rst), .en(en), .OUT(out), .instr(instr), .register1(register1), .register2(register2), .PC(PC), .imm_J(imm_J));

always #10 clk = ~clk;

endmodule
