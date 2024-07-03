`timescale 1ns / 1ps


module dec7(
            input    [6:0]  SW,
            output   [7:0]  AN,
            output   [6:0]  HEX
            );

assign AN[0] = 1'b0;
assign AN[1] = 1'b0;
assign AN[2] = 1'b0;
assign AN[3] = 1'b0;
assign HEX[6:0] = SW[6:0];            

endmodule
