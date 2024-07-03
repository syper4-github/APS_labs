`timescale 1ns / 1ps


module RISC_V(
              input         CLK,
              input         rst,
              input         en,
              input  [31:0] IN,
              output [31:0] OUT
//              output [31:0] register1,
//              output [31:0] register2,
//              output [31:0] register3,
//              output reg [31:0] WD3,
//              output [31:0] RD,
//              output reg [7:0] A = 8'b0000000
    );

reg [7:0] A = 8'b00000000;
wire [31:0] RD;
wire sel_counter;
wire [7:0] mux_counter;
wire WE3;
reg [31:0] WD3;
wire [31:0] RD1;
wire [31:0] RD2;
wire [31:0] ALU_Res;
wire ALU_Flag;
wire [31:0] SignExtend;

assign OUT = RD1;

IM InstructionMemory ( .A(A), .RD(RD) );
RF RegisterFile ( .clk(CLK), .adr1(RD[22:18]), .adr2(RD[17:13]), .adr3(RD[4:0]), .wd(WD3), .we(WE3), .rd1(RD1), .rd2(RD2));
ALU ALU ( .A(RD1), .B(RD2), .ALUOp(RD[27:23]), .Result(ALU_Res), .Flag(ALU_Flag));

always@ (posedge (CLK || rst))
begin
    case (rst)
        1'b0: begin
                if (en)
                    A <= A + mux_counter;
                else
                    A <= A;
              end
        1'b1:
            A <= 8'b00000000;
    endcase
end

assign sel_counter = (ALU_Flag && RD[30]) || RD[31];

assign mux_counter = sel_counter ? RD[12:5] : 8'b00000001;

assign WE3 = RD[29] || RD[28];

assign SignExtend = {{24{RD[12]}}, RD[12:5]};

always@*
begin
     case(RD[29:28])
        2'b01:
            WD3 <= IN;
        2'b10:
            WD3 <= SignExtend;
        2'b11:
            WD3 <= ALU_Res;
        default:
            WD3 <= WD3;
     endcase
end

endmodule
