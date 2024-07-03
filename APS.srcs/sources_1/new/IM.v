`timescale 1ns / 1ps

module IM(
          input  [31:0] A,
          output [31:0] RD
    );

reg [31:0] InstrMem [0:255];

initial $readmemh ("Instructions.txt", InstrMem);

assign RD = InstrMem[A[9:2]];

endmodule
