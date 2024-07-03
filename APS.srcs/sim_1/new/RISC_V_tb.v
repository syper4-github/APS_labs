`timescale 1ns / 1ps

module RISC_V_tb();
    reg         clk = 1'b0;
    reg         rst;
    reg         en;
    reg  [31:0] switches;
    wire [31:0] out;
//    wire [31:0] register1;
//    wire [31:0] register2;
//    wire [31:0] register3;
//    wire [31:0] WD3;
//    wire [31:0] RD;
//    wire [7:0] A;
// ((A - B) ^ (B - A)) << 2
RISC_V inst1 ( .CLK(clk), .rst(rst), .en(en), .IN(switches), .OUT(out));

always #10 clk = ~clk;

task RISC_V_test;
    input integer rst_tb;
    input integer en_tb;
    input integer switches_tb;
    
    begin
        rst = rst_tb;
        en = en_tb;
        switches = switches_tb;
    end
endtask

initial begin
// ((35 + 4) ^ (4 - 35)) << 2 = -232
RISC_V_test(0, 1, 35);
#140;
$display("rst = %d", rst, " switches = %d", switches, " OUT = %d", out);
$display("Time = %t", $realtime);
if (out === 32'b11111111111111111111111100011000)
    $display("Good");
else
    $display("Bad");
//#60
//rst = 1'b1;
//#15
//rst = 1'b0;
end

endmodule
