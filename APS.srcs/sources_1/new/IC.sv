`timescale 1ns / 1ps

module IC(
          input             clk,
          input             INT_RST,
          input      [31:0] mie,
          input      [31:0] int_req,
          output reg [31:0] mcause,
          output reg [31:0] int_fin,
          output            INT
    );

reg [31:0] bus_FOR_OR;
wire FOR_OR;
reg buff_reg_out;
reg [4:0] out_sum = 5'b0;
reg [4:0] out_reg_sum = 5'b0;
//reg [31:0] counter = 32'b0;

reg buf_mie;
reg buf_int_req;
reg [5:0] i = 0;
//assign INT = buff_reg_out ^ FOR_OR;
assign INT = FOR_OR & !buff_reg_out;


always @(posedge clk) begin
     buff_reg_out <=  INT_RST ? 1'b0 : FOR_OR;
     if(INT_RST)
          out_reg_sum <= 5'b0;
     else
          if(!FOR_OR)
              out_reg_sum <= out_sum;
end
    
always @(*) begin
    out_sum = out_reg_sum + 5'b1;
    mcause = {{27'h0000000} , out_reg_sum};
    if(int_req != 32'b0 && FOR_OR != 1'b1)
        begin
        i = 0;
        end
end

assign FOR_OR = | bus_FOR_OR;

always @(*) begin
    i = 0;
    while(i != 32)
        begin
            //counter = counter + 32'b1;
            if(out_reg_sum == i[4:0])
                begin
                    bus_FOR_OR[i[4:0]] = (mie[i[4:0]] & int_req[i[4:0]]);
                    int_fin[i[4:0]] = INT_RST & (mie[i[4:0]] & int_req[i[4:0]]);
                end
            else
                begin
                    int_fin[i[4:0]] = 1'b0; 
                    bus_FOR_OR[i[4:0]] = 1'b0;
                end
            i = i + 1;
        end
end

endmodule
