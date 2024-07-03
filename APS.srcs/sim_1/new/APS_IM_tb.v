`timescale 1ns / 1ps

module APS_IM_tb();
    reg  [7:0]  A;
    wire  [31:0]  RD;
    
IM inst2 ( .A(A), .RD(RD));

task IM_test;
    input integer A_tb;
    begin
    A = A_tb;
    #10;
    $display("A = %d", A, " RD = %d", RD);
    $display("Time = %t", $realtime);
    end
endtask
initial begin
IM_test(8'b00000000);
#20;
if (RD === 32'b00010000000000000000000000000001)
    $display("Good");
else
    $display("Bad");
IM_test(8'b00000001);
#20;
if (RD === 32'b00100000000000000000000010000010)
    $display("Good");
else
    $display("Bad");
IM_test(8'b00000010);
#20;
if (RD === 32'b00110000000001000100000000000011)
    $display("Good");
else
    $display("Bad");
IM_test(8'b00000011);
#20;
if (RD === 32'b00000000000000000000000000000000)
    $display("Good");
else
    $display("Bad");
end
endmodule
