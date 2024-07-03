`timescale 1ns / 1ps

module CSR(
           input             clk,
           input      [2:0]  OP,
           input      [31:0] WD,
           input      [31:0] mcause,
           input      [31:0] PC,
           input      [11:0] A,
           output reg [31:0] mie,
           output reg [31:0] mtvec,
           output reg [31:0] mepc,
           output reg [31:0] RD
    );

reg [31:0] WD_interior;
reg [31:0] mscratch;
reg [31:0] mcause_interior;
reg mepc_or;
reg mcause_or;
wire op0_op1;
reg  enable1 = 1'b0;
reg  enable2 = 1'b0;
reg  enable3 = 1'b0;
wire enable4;
wire enable5;
reg [31:0] buffer_PC;
reg [31:0] buffer_1;
reg [31:0] buffer_2;
reg [31:0] buffer_3; //mscratch reg
reg [31:0] buffer_4;
reg [31:0] buffer_5;
reg [31:0] WD_interior_4;
reg [31:0] WD_interior_5;

assign op0_op1 = OP[1] | OP[0];
assign enable4 = OP[2] | mepc_or;
assign enable5 = OP[2] | mcause_or;

always @(*) begin
    case ( OP[1:0] )
        2'b00:
            WD_interior <= 32'b0;
        2'b01:
            WD_interior <= WD;
        2'b10:
            WD_interior <= WD | RD;
        2'b11:
            WD_interior <= ~(WD) & RD;
        default:
            WD_interior <= 32'b0;
    endcase
end

always @(posedge clk) begin
    buffer_PC <= PC;
    buffer_1 <= enable1 ? WD_interior : buffer_1;
    buffer_2 <= enable2 ? WD_interior : buffer_2;
    buffer_3 <= enable3 ? WD_interior : buffer_3;
    buffer_4 <= enable4 ? WD_interior_4 : buffer_4;
    buffer_5 <= enable5 ? WD_interior_5 : buffer_5;
end

always @(*) begin
    case ( A )
        12'h304:
                RD = buffer_1;
            12'h305:
                RD = buffer_2;                                
            12'h340:
                RD = buffer_3;
            12'h341:
                RD = buffer_4;
            12'h342:
                RD = buffer_5;
            default:
                RD = 32'b0;
    endcase
    mie = buffer_1;
    mtvec = buffer_2;
    mepc = buffer_4;
    WD_interior_4 = OP[2] ? buffer_PC : WD_interior;
    WD_interior_5 = OP[2] ? mcause : WD_interior;
end

always @(*) begin
    case ( A )
        12'h304:
            begin
            enable1 = op0_op1;
            enable2 = 0;     
            enable3 = 0;     
            mepc_or = 0;  
            mcause_or = 0;
            end
        12'h305:
            begin
            enable1 = 0;
            enable2 = op0_op1;     
            enable3 = 0;     
            mepc_or = 0;  
            mcause_or = 0;
            end                                
        12'h340:
            begin
            enable1 = 0;
            enable2 = 0;     
            enable3 = op0_op1;     
            mepc_or = 0;  
            mcause_or = 0;
            end 
        12'h341:
            begin
            enable1 = 0;
            enable2 = 0;     
            enable3 = 0;     
            mepc_or = op0_op1; 
            mcause_or = 0;
            end 
        12'h342:
            begin
            enable1 = 0;
            enable2 = 0;     
            enable3 = 0;     
            mepc_or = 0; 
            mcause_or = op0_op1;
            end 
        default:
            begin
            enable1 = 0;
            enable2 = 0;
            enable3 = 0;
            mepc_or = 0;
            mcause_or = 0;
            end
    endcase                
end

endmodule
