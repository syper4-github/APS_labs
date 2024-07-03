`timescale 1ns / 1ps

module RF(
                input         clk,
                input  [4:0]  adr1,
                input  [4:0]  adr2,
                input  [4:0]  adr3,
                input  [31:0] wd,
                input         we,
                output [31:0] rd1,
                output [31:0] rd2
                //output [31:0] register1,
                //output [31:0] register2
//                output [31:0] register3
    );

reg [31:0] RAM [0:31];

assign rd1 = ( adr1 == 5'b00000 ) ? 32'b00000000000000000000000000000000 : RAM[adr1];
assign rd2 = ( adr2 == 5'b00000 ) ? 32'b00000000000000000000000000000000 : RAM[adr2];

//assign register1 = RAM[1];
//assign register2 = RAM[2];
//assign register3 = RAM[3];

always@ (posedge clk)
    if (we) RAM[adr3] <= wd;

endmodule
