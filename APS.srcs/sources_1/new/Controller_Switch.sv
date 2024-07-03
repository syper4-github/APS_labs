`timescale 1ns / 1ps

module Controller_Switch(
                         input  logic        clk,
                         //input  logic [31:0] sw_address,
                         input  logic        int_fin_sw_i,
                         output logic        int_req_sw_o = 1'b0,
                         //input  logic        we_d1,
                         input  logic [15:0] sw_16,
                         output logic [31:0] rdata
    );
logic [31:0] sw_32 = 32'b0;

assign rdata = sw_32;

always_ff @(posedge clk) begin
   if(sw_32 != {{16{1'b0}}, sw_16}) begin
        int_req_sw_o <= 1'b1;
        sw_32 <= {{16{1'b0}}, sw_16};
   end
   else if(int_fin_sw_i == int_req_sw_o)
        int_req_sw_o <= 1'b0;
end  

endmodule
