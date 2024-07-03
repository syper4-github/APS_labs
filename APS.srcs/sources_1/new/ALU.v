`timescale 1ns / 1ps

`define ALU_ADD  5'b00000
`define ALU_SUB  5'b01000
`define ALU_SLL  5'b00001
`define ALU_SLT  5'b00010
`define ALU_SLTU 5'b00011
`define ALU_XOR  5'b00100
`define ALU_SRL  5'b00101
`define ALU_SRA  5'b01101
`define ALU_OR   5'b00110
`define ALU_AND  5'b00111
`define ALU_BEQ  5'b11000
`define ALU_BNE  5'b11001
`define ALU_BLT  5'b11100
`define ALU_BGE  5'b11101
`define ALU_BLTU 5'b11110
`define ALU_BGEU 5'b11111

module ALU( A, B, ALUOp, Result, Flag );
           parameter WIDTH = 32;
           input      [WIDTH-1:0]  A;
           input      [WIDTH-1:0]  B;
           input      [4:0]        ALUOp;
           output reg [WIDTH-1:0]  Result;
           output reg              Flag;
always@(*)
begin
    case(ALUOp)
        `ALU_ADD: begin
                Result <= A + B;
                Flag <= 1'b0;
            end
        `ALU_SUB: begin
                Result <= A - B;
                Flag <= 1'b0;
            end
        `ALU_SLL: begin
                Result <= A << B;
                Flag <= 1'b0;
            end
        `ALU_SLT: begin
                Result <= ($signed(A) < $signed(B)) ? 1 : 0;
                Flag <= 1'b0;
            end
        `ALU_SLTU: begin
                Result <= (A < B) ? 1 : 0;
                Flag <= 1'b0;
            end
        `ALU_XOR: begin
                Result <= A ^ B;
                Flag <= 1'b0;
            end
        `ALU_SRL: begin
                Result <= A >> B;
                Flag <= 1'b0;
            end
        `ALU_SRA: begin
                Result <= $signed(A) >>> B;
                Flag <= 1'b0;
            end
        `ALU_OR: begin
                Result <= A | B;
                Flag <= 1'b0;
            end
        `ALU_AND: begin
                Result <= A & B;
                Flag <= 1'b0;
            end
        `ALU_BEQ: begin
                Result <= 1'b0;
                Flag <= (A == B) ? 1 : 0;
            end
        `ALU_BNE: begin
                Result <= 1'b0;
                Flag <= (A != B) ? 1 : 0;
            end
        `ALU_BLT: begin
                Result <= 1'b0;
                Flag <= ($signed(A) < $signed(B)) ? 1 : 0;
            end
        `ALU_BGE: begin
                Result <= 1'b0;
                Flag <= ($signed(A) >= $signed(B)) ? 1 : 0;
            end
        `ALU_BLTU: begin
                Result <= 1'b0;
                Flag <= (A < B) ? 1 : 0;
            end
        `ALU_BGEU: begin
                Result <= 1'b0;
                Flag <= (A >= B) ? 1 : 0;
            end
        default: begin
                Result <= 1'b0;
                Flag <= 1'b0;
            end
    endcase 
end
endmodule
