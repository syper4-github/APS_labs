`timescale 1ns / 1ps

module DM(
          input         CLK,
          input  [31:0] A,
          input  [31:0] WD,
          input         WE,
          output [31:0] RD
    );

reg [31:0] RAM [0:255];

initial $readmemb("Data.txt", RAM); 

assign RD = ((A[31:10] == 22'b0010100000000000000000) && (A[1:0] == 2'b00)) ? RAM[A[9:2]] : 32'b0;

always@ (posedge CLK)
    if (WE) RAM[A[9:2]] <= WD;

endmodule
