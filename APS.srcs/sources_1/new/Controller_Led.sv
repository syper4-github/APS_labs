`timescale 1ns / 1ps

module Controller_Led(
                      input  logic        clk,
                      //input  logic [31:0] led_address,
                      input  logic [31:0] led_wdata,
                      input  logic        we_d0,
                      input  logic [3:0]  be_d0,
                      output logic [31:0] rdata,
                      output logic [15:0] led_reg
    );

assign rdata = {{16{1'b0}}, led_reg};

always @(posedge clk) begin
    if(we_d0) begin
        case(be_d0)
            4'b0011:
                led_reg = led_wdata[15:0];
            4'b1100:
                led_reg = led_wdata[31:16];
            default:
                led_reg = led_reg;
        endcase
    end
end

endmodule
