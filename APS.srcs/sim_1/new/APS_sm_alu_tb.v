`timescale 1ns / 1ps

`define ALU_ADD  5'b00000
`define ALU_SUB  5'b01000
`define ALU_SLL  5'b00001
`define ALU_SLT  5'b00010
`define ALU_SLTU 5'b00011
`define ALU_XOR  5'b00100
`define ALU_SRL  5'b00101
`define ALU_SRA  5'b01101
`define ALU_OR   5'b00110
`define ALU_AND  5'b00111
`define ALU_BEQ  5'b11000
`define ALU_BNE  5'b11001
`define ALU_BLT  5'b11100
`define ALU_BGE  5'b11101
`define ALU_BLTU 5'b11110
`define ALU_BGEU 5'b11111

module APS_sm_alu_tb();
    reg  [3:0] srcA;
    reg  [3:0] srcB;
    reg  [4:0] oper;
    wire [3:0] result;
    wire       flag;
    
ALU inst2 ( .A(srcA), .B(srcB), .ALUOp(oper), .Result(result), .Flag(flag) );

reg [5:0] k = 6'b000000;
task alu_oper_test;
    input integer oper_tb;
    input integer srcA_tb;
    input integer srcB_tb;

    begin
    oper = oper_tb;
    srcA = srcA_tb;
    srcB = srcB_tb;
    #10;
    $display("srcA = %d", srcA, " srcB = %d", srcB, " result = %d", result, " flag = %d", flag);
    $display("Time = %t", $realtime);
    end
endtask
initial begin
alu_oper_test(`ALU_ADD, 1, 2);
#20;
if (result === 3 && flag === 0)
    k = k + 1'b1;
alu_oper_test(`ALU_ADD, 6, 5);
#20;
if (result === 11 && flag === 0)
    k = k + 1'b1;
alu_oper_test(`ALU_SUB, 4, 2);
#20;
if (result === 2 && flag === 0)
    k = k + 1'b1;
alu_oper_test(`ALU_SUB, 14, 7);
#20;
if (result === 7 && flag === 0)
    k = k + 1'b1;
alu_oper_test(`ALU_SLL, 5, 1);
#20;
if (result === 10 && flag === 0)
    k = k + 1'b1;
alu_oper_test(`ALU_SLL, 6, 1);
#20;
if (result === 12 && flag === 0)
    k = k + 1'b1;
alu_oper_test(`ALU_SLT, -5, 2);
#20;
if (result === 1 && flag === 0)
    k = k + 1'b1;
alu_oper_test(`ALU_SLT, 4, -7);
#20;
if (result === 0 && flag === 0)
    k = k + 1'b1;
alu_oper_test(`ALU_SLTU, 6, 3);
#20;
if (result === 0 && flag === 0)
    k = k + 1'b1;
alu_oper_test(`ALU_SLTU, 1, 2);
#20;
if (result === 1 && flag === 0)
    k = k + 1'b1;
alu_oper_test(`ALU_XOR, 10, 5);
#20;
if (result === 15 && flag === 0)
    k = k + 1'b1;
alu_oper_test(`ALU_XOR, 7, 6);
#20;
if (result === 1 && flag === 0)
    k = k + 1'b1;
alu_oper_test(`ALU_SRL, 10, 1);
#20;
if (result === 5 && flag === 0)
    k = k + 1'b1;
alu_oper_test(`ALU_SRL, 10, 2);
#20;
if (result === 2 && flag === 0)
    k = k + 1'b1;
alu_oper_test(`ALU_SRA, -5, 2);
#20;
if (result === 14 && flag === 0)
    k = k + 1'b1;
alu_oper_test(`ALU_SRA, 6, 2);
#20;
if (result === 1 && flag === 0)
    k = k + 1'b1;
alu_oper_test(`ALU_OR, 6, 8);
#20;
if (result === 14 && flag === 0)
    k = k + 1'b1;
alu_oper_test(`ALU_OR, 3, 6);
#20;
if (result === 7 && flag === 0)
    k = k + 1'b1;
alu_oper_test(`ALU_AND, 3, 2);
#20;
if (result === 2 && flag === 0)
    k = k + 1'b1;
alu_oper_test(`ALU_AND, 8, 1);
#20;
if (result === 0 && flag === 0)
    k = k + 1'b1;
alu_oper_test(`ALU_BEQ, 3, 5);
#20;
if (result === 0 && flag === 0)
    k = k + 1'b1;
alu_oper_test(`ALU_BEQ, 8, 8);
#20;
if (result === 0 && flag === 1)
    k = k + 1'b1;
alu_oper_test(`ALU_BNE, 3, 5);
#20;
if (result === 0 && flag === 1)
    k = k + 1'b1;
alu_oper_test(`ALU_BNE, -1, -1);
#20;
if (result === 0 && flag === 0)
    k = k + 1'b1;
alu_oper_test(`ALU_BLT, -4, -2);
#20;
if (result === 0 && flag === 1)
    k = k + 1'b1;
alu_oper_test(`ALU_BLT, 4, 1);
#20;
if (result === 0 && flag === 0)
    k = k + 1'b1;
alu_oper_test(`ALU_BGE, 7, -8);
#20;
if (result === 0 && flag === 1)
    k = k + 1'b1;
alu_oper_test(`ALU_BGE, -8, -3);
#20;
if (result === 0 && flag === 0)
    k = k + 1'b1;
alu_oper_test(`ALU_BLTU, 2, 7);
#20;
if (result === 0 && flag === 1)
    k = k + 1'b1;
alu_oper_test(`ALU_BLTU, 8, 4);
#20;
if (result === 0 && flag === 0)
    k = k + 1'b1;
alu_oper_test(`ALU_BGEU, 1, 9);
#20;
if (result === 0 && flag === 0)
    k = k + 1'b1;
alu_oper_test(`ALU_BGEU, 5, 5);
#20;
if (result === 0 && flag === 1)
    k = k + 1'b1;
#20
if ( k === 6'b100000 )
    $display("Good");
else
    $display("Bad");
end
endmodule
