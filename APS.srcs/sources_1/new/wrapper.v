`timescale 1ns / 1ps

module wrapper(
               input         CLK100MHZ,
               input         CPU_RESETN,
               input  [15:0] SW,
               output [15:0] LED
               );


//wire reset = 1'b1;
//assign LED = SW;
miriscv_top Processor ( .clk_100M(CLK100MHZ), .rst_n_i(CPU_RESETN), .sw_i(SW[15:0]), .led_o(LED[15:0]) );

endmodule
