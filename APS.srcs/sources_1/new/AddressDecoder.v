`timescale 1ns / 1ps
`define LED_ADDR    32'h80000000
`define SW_ADDR    32'h80001000

module AddressDecoder(
                      input      [31:0] addr,
                      input             we,
                      input             req,
                      
                      output reg        we_m,
                      output reg        req_m,
                      output            we_d0,
                      //output            we_d1,
                      output reg [1:0]  RDsel
    );

initial RDsel = 2'b0;
//assign we_d1 = req & (addr == `SW_ADDR);
assign we_d0 = req & we & (addr == `LED_ADDR);
    
always @(*)
    if(addr[31] == 0)
        begin
        RDsel = 2'b00;
        we_m = we;
        req_m = req;
        end
    else
        begin
        we_m = 0;
        req_m = 0;
            case(addr[15:12])
                4'h0: //led_controller
                    begin
                    RDsel = 2'b01;
                    end
                4'h1: //switch_controller
                    begin
                    RDsel = 2'b10;
                    end
                default:
                    begin
                    RDsel = 2'b00;
                    end
            endcase
        end

endmodule
