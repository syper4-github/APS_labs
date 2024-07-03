`timescale 1ns / 1ps

module RISC_V_Processor(
                        input         CLK,
                        input         rst,
                        input         en,
                        output [31:0] OUT,
                        output [31:0] instr,
                        output [31:0] register1,
                        output [31:0] register2,
                        output reg [31:0] PC,
                        output [31:0] imm_J
    );

initial PC = 32'b0;
//reg  [31:0] PC = 32'b0;
wire [31:0] RD_DM;
wire [31:0] PC_adder_o;
wire [31:0] WD3;
wire [31:0] RD1;
wire [31:0] RD2;
wire [31:0] ALU_Res;
wire comp;
wire [31:0] imm_I;
wire [31:0] imm_S;
//wire [31:0] imm_J;
wire [31:0] imm_B;
reg  [31:0] Operand1;
reg  [31:0] Operand2;
// decoder
// wire [31:0] instr;
wire jalr_o;
wire illegal_instr_o;
wire jal_o;
wire branch_o;
wire wb_src_sel_o;
wire mem_req_o;
wire [2:0] mem_size_o;
wire mem_we_o;
wire [4:0] alu_op_o;
wire [2:0] ex_op_b_sel_o;
wire [1:0] ex_op_a_sel_o;
wire gpr_we_a_o;
wire [31:0] PC_mux;

IM InstructionMemory ( .A(PC), .RD(instr) );
RF RegisterFile ( .clk(CLK), .adr1(instr[19:15]), .adr2(instr[24:20]), .adr3(instr[11:7]), .wd(WD3), .we(gpr_we_a_o), .rd1(RD1), .rd2(RD2), .register1(register1), .register2(register2));
DM DataMemory ( .CLK(CLK), .A(ALU_Res), .WD(RD2), .WE(mem_we_o), .RD(RD_DM));
ALU ALU ( .A(Operand1), .B(Operand2), .ALUOp(alu_op_o), .Result(ALU_Res), .Flag(comp));
RISC_V_decode MainDecoder ( .fetched_instr_i(instr),
                            .ex_op_a_sel_o(ex_op_a_sel_o),
                            .ex_op_b_sel_o(ex_op_b_sel_o),
                            .alu_op_o(alu_op_o),
                            .mem_req_o(mem_req_o),
                            .mem_we_o(mem_we_o),
                            .mem_size_o(mem_size_o),
                            .gpr_we_a_o(gpr_we_a_o),
                            .wb_src_sel_o(wb_src_sel_o),
                            .illegal_instr_o(illegal_instr_o),
                            .branch_o(branch_o),
                            .jal_o(jal_o),
                            .jalr_o(jalr_o) );

always@ (posedge ( CLK || rst))
begin
    if (rst)
        PC <= 32'b0;
    else
        begin
            if (en)
                PC <= ( jalr_o ) ? ( RD1 + imm_I ) : PC_adder_o;
        end
end

assign imm_I = {{20{instr[31]}}, instr[31:20]};
assign imm_S = {{20{instr[31]}}, instr[31:25], instr[11:7]};
assign imm_J = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
assign imm_B = {{9{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};

assign PC_mux = branch_o ? imm_B : imm_J;

assign PC_and = comp & branch_o;

assign PC_or = jal_o | PC_and;

assign PC_adder_o = PC + ( PC_or ? PC_mux : 32'b00000000000000000000000000000100);

always@*
begin
    case (ex_op_a_sel_o)
        2'b00:
            Operand1 <= RD1;
        2'b01:
            Operand1 <= PC;
        2'b10:
            Operand1 <= 32'b0;
        default:
            Operand1 <= RD1;
    endcase
end

always@*
begin
    case (ex_op_b_sel_o)
        3'b000:
            Operand2 <= RD2;
        3'b001:
            Operand2 <= imm_I;
        3'b010:
            Operand2 <= {instr[31:12], 12'b0};
        3'b011:
            Operand2 <= imm_S;
        3'b100:
            Operand2 <= 32'b00000000000000000000000000000100;
        default:
            Operand2 <= RD2;
    endcase
end

assign WD3 = ( wb_src_sel_o ) ? RD_DM : ALU_Res;

assign OUT = RD2;

endmodule
