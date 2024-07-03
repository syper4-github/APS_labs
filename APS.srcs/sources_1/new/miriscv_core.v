`timescale 1ns / 1ps

module miriscv_core(
                    input         clk_i,
                    input         arstn_i,
                    input  [31:0] instr_rdata_i,
                    input  [31:0] data_rdata_i,
                    output [31:0] instr_addr_o,
                    output        data_req_o,
                    output        data_we_o,
                    output [3:0]  data_be_o,
                    output [31:0] data_addr_o,
                    output [31:0] data_wdata_o,
                    input         INT,
                    output        INT_RST,
                    input  [31:0] mcause,
                    output [31:0] mie
                    // added for tb
                    //output reg [31:0] PC
                    //output [31:0] register1,
                    //output [31:0] register2
                    //output lsu_req_o,
                    //output lsu_we_o,
                    //output [31:0] ALU_Res,
                    //output [31:0] RD2,
                    //output [2:0] lsu_size_o,
                    //output [31:0] RD,
                    //output en_pc
    );
//initial PC = 32'b0;
reg  [31:0] PC = 32'b0;
wire en_pc;
wire [31:0] RD;
wire [31:0] PC_adder_o;
wire [31:0] WD3;
wire [31:0] RD1;
wire [31:0] RD2;
wire [31:0] ALU_Res;
wire comp;
wire [31:0] imm_I;
wire [31:0] imm_S;
wire [31:0] imm_J;
wire [31:0] imm_B;
reg  [31:0] Operand1;
reg  [31:0] Operand2;
wire [11:0] CSR_A;
wire [31:0] RD_csr;
wire [31:0] mepc;
wire [31:0] mtvec;
wire        csr_i;
wire [2:0]  CSRop;

assign CSR_A = instr_rdata_i[31:20];

// decoder
wire [1:0] jalr_o;
wire       illegal_instr_o;
wire       jal_o;
wire       branch_o;
wire       wb_src_sel_o;
wire       lsu_req_o;
wire       [2:0] lsu_size_o;
wire       lsu_we_o;
wire       [4:0] alu_op_o;
wire       [2:0] ex_op_b_sel_o;
wire       [1:0] ex_op_a_sel_o;
wire       gpr_we_a_o;
wire       [31:0] PC_mux;
wire       PC_and;
wire       PC_or;
wire       stall;

miriscv_lsu LSU            ( .clk_i(clk_i),
                             .arstn_i(arstn_i),
                             .lsu_addr_i(ALU_Res),
                             .lsu_we_i(lsu_we_o),
                             .lsu_size_i(lsu_size_o),
                             .lsu_data_i(RD2),
                             .lsu_req_i(lsu_req_o),
                             .lsu_stall_req_o(stall),
                             .lsu_data_o(RD),
                             .data_rdata_i(data_rdata_i),
                             .data_req_o(data_req_o),
                             .data_we_o(data_we_o),
                             .data_be_o(data_be_o),
                             .data_addr_o(data_addr_o),
                             .data_wdata_o(data_wdata_o) );
RF RegisterFile            ( .clk(clk_i),
                             .adr1(instr_rdata_i[19:15]),
                             .adr2(instr_rdata_i[24:20]),
                             .adr3(instr_rdata_i[11:7]),
                             .wd(WD3),
                             .we(gpr_we_a_o),
                             .rd1(RD1),
                             .rd2(RD2) );
                             //added for tb
                             //.register1(register1),
                             //.register2(register2) );
ALU ALU                    ( .A(Operand1),
                             .B(Operand2),
                             .ALUOp(alu_op_o),
                             .Result(ALU_Res),
                             .Flag(comp));
RISC_V_decode MainDecoder  ( .fetched_instr_i(instr_rdata_i),
                             .ex_op_a_sel_o(ex_op_a_sel_o),
                             .ex_op_b_sel_o(ex_op_b_sel_o),
                             .alu_op_o(alu_op_o),
                             .mem_req_o(lsu_req_o),
                             .mem_we_o(lsu_we_o),
                             .mem_size_o(lsu_size_o),
                             .gpr_we_a_o(gpr_we_a_o),
                             .wb_src_sel_o(wb_src_sel_o),
                             .illegal_instr_o(illegal_instr_o),
                             .branch_o(branch_o),
                             .jal_o(jal_o),
                             .jalr_o(jalr_o),
                             .stall(stall),
                             .en_pc(en_pc),
                             .INT(INT),
                             .INT_RST(INT_RST),
                             .CSRop(CSRop),
                             .csr(csr_i) );
CSR CSR                    ( .clk(clk_i),
                             .OP(CSRop),
                             .WD(RD1),
                             .mcause(mcause),
                             .PC(PC),
                             .A(CSR_A),
                             .mie(mie),
                             .mtvec(mtvec),
                             .mepc(mepc),
                             .RD(RD_csr)
                            );

assign instr_addr_o = PC;

always@ (posedge clk_i)
begin
    if (!arstn_i)
        PC <= 32'b0;
    else
        begin
            if (!en_pc) begin
                case ( jalr_o )
                    2'b00:
                        PC <= PC_adder_o;
                    2'b01:
                        PC <= RD1 + imm_I;
                    2'b10:
                        PC <= mepc;
                    2'b11:
                        PC <= mtvec;
                endcase
            end
        end
end

assign imm_I = {{20{instr_rdata_i[31]}}, instr_rdata_i[31:20]};
assign imm_S = {{20{instr_rdata_i[31]}}, instr_rdata_i[31:25], instr_rdata_i[11:7]};
assign imm_J = {{12{instr_rdata_i[31]}}, instr_rdata_i[19:12], instr_rdata_i[20], instr_rdata_i[30:21], 1'b0};
assign imm_B = {{20{instr_rdata_i[31]}}, instr_rdata_i[7], instr_rdata_i[30:25], instr_rdata_i[11:8], 1'b0};

assign PC_mux = branch_o ? imm_B : imm_J;

assign PC_and = comp & branch_o;

assign PC_or = jal_o | PC_and;

assign PC_adder_o = PC + (PC_or ? PC_mux : 32'b00000000000000000000000000000100);

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
            Operand2 <= {instr_rdata_i[31:12], 12'b0};
        3'b011:
            Operand2 <= imm_S;
        3'b100:
            Operand2 <= 32'b00000000000000000000000000000100;
        default:
            Operand2 <= RD2;
    endcase
end

assign WD3 = csr_i ? RD_csr : ( ( wb_src_sel_o ) ? RD : ALU_Res );

endmodule
