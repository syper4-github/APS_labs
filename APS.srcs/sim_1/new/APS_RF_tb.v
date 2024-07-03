`timescale 1ns / 1ps

module APS_RF_tb();
    reg         clk;
    reg  [4:0]  A1;
    reg  [4:0]  A2;
    reg  [4:0]  A3;
    reg  [31:0] WD3;
    reg         we;
    wire [31:0] RD1;
    wire [31:0] RD2;
    
RF inst2 ( .clk(clk), .adr1(A1), .adr2(A2), .adr3(A3), .wd(WD3), .we(we), .rd1(RD1), .rd2(RD2));

initial we = 1'b1;
initial clk = 1'b0;

always #1 clk = ~clk;

task RF_test;
    input integer A1_tb;
    input integer A2_tb;
    input integer A3_tb;
    input integer WD3_tb;

    begin
    A1 = A1_tb;
    A2 = A2_tb;
    A3 = A3_tb;
    WD3 = WD3_tb;
    #10;
    $display("A1 = %d", A1, " A2 = %d", A2, " A3 = %d", A3, " WD3 = %d", WD3, " RD1 = %d", RD1, " RD2 = %d", RD2);
    $display("Time = %t", $realtime);
    end
endtask
initial begin
RF_test(5'b00000, 5'b00000, 5'b00001, 32'b00000000000000011001000100101000);
#10;
RF_test(5'b00001, 5'b00000, 5'b00010, 32'b01000001100000011001000100101000);
#10;
if (RD1 === 32'b00000000000000011001000100101000 & RD2 === 32'b00000000000000000000000000000000)
    $display("Good");
else
    $display("Bad");
RF_test(5'b00001, 5'b00010, 5'b00000, 32'b00000000000000000000000000000000);
#10;
if (RD1 === 32'b00000000000000011001000100101000 & RD2 === 32'b01000001100000011001000100101000)
    $display("Good");
else
    $display("Bad");
end
endmodule
