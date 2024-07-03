`timescale 1ns / 1ps

`define RESET_ADDR 32'h00000000

`define ALU_OP_WIDTH  5

`define ALU_ADD   5'b00000
`define ALU_SUB   5'b01000

`define ALU_XOR   5'b00100
`define ALU_OR    5'b00110
`define ALU_AND   5'b00111

// shifts
`define ALU_SRA   5'b01101
`define ALU_SRL   5'b00101
`define ALU_SLL   5'b00001

// comparisons
`define ALU_LTS   5'b11100
`define ALU_LTU   5'b11110
`define ALU_GES   5'b11101
`define ALU_GEU   5'b11111
`define ALU_EQ    5'b11000
`define ALU_NE    5'b11001

// set lower than operations
`define ALU_SLTS  5'b00010
`define ALU_SLTU  5'b00011

// opcodes
`define LOAD_OPCODE      5'b00_000
`define MISC_MEM_OPCODE  5'b00_011
`define OP_IMM_OPCODE    5'b00_100
`define AUIPC_OPCODE     5'b00_101
`define STORE_OPCODE     5'b01_000
`define OP_OPCODE        5'b01_100
`define LUI_OPCODE       5'b01_101
`define BRANCH_OPCODE    5'b11_000
`define JALR_OPCODE      5'b11_001
`define JAL_OPCODE       5'b11_011
`define SYSTEM_OPCODE    5'b11_100

// dmem type load store
`define LDST_B           3'b000
`define LDST_H           3'b001
`define LDST_W           3'b010
`define LDST_BU          3'b100
`define LDST_HU          3'b101

// operand a selection
`define OP_A_RS1         2'b00
`define OP_A_CURR_PC     2'b01
`define OP_A_ZERO        2'b10

// operand b selection
`define OP_B_RS2         3'b000
`define OP_B_IMM_I       3'b001
`define OP_B_IMM_U       3'b010
`define OP_B_IMM_S       3'b011
`define OP_B_INCR        3'b100

// writeback source selection
`define WB_EX_RESULT     1'b0
`define WB_LSU_DATA      1'b1

module RISC_V_decode(
                     input      [31:0]              fetched_instr_i,
                     output reg [1:0]               ex_op_a_sel_o,
                     output reg [2:0]               ex_op_b_sel_o,
                     output reg [`ALU_OP_WIDTH-1:0] alu_op_o,
                     output reg                     mem_req_o,
                     output reg                     mem_we_o,
                     output reg [2:0]               mem_size_o,
                     output reg                     gpr_we_a_o,
                     output reg                     wb_src_sel_o,
                     output reg                     illegal_instr_o,
                     output reg                     branch_o,
                     output reg                     jal_o,
                     output reg [1:0]               jalr_o,
                     
                     input                          stall,
                     output reg                     en_pc,
                     output reg                     INT_RST,
                     input                          INT,
                     output reg [2:0]               CSRop,
                     output reg                     csr
    );

always @ (*)
begin
    if(INT) begin
        jalr_o <= 2'b11;
        CSRop <= 3'b100;
        csr <= 1'b1;
        mem_we_o <= 1'b0;
        en_pc <= 1'b0;
        wb_src_sel_o <= 1'b0;
        ex_op_a_sel_o <= 2'b00;
        ex_op_b_sel_o <= 3'b000;
        mem_req_o <= 1'b0;
        mem_size_o <= 3'b0;
        gpr_we_a_o <= 1'b0;
        illegal_instr_o <= 1'b0;
        branch_o <= 1'b0;
        jal_o <= 1'b0;
        INT_RST <= 1'b0;
        alu_op_o <= 5'b0;
    end else
    begin
        en_pc <= stall;
        wb_src_sel_o <= 1'b0;
        ex_op_a_sel_o <= 2'b00;
        ex_op_b_sel_o <= 3'b000;
        alu_op_o <= 5'b0;
        mem_size_o <= 3'b0;
        case ( fetched_instr_i[1:0] )
            2'b11: begin
                        mem_req_o <= 1'b0;
                        branch_o <= 1'b0;
                        jalr_o <= 2'b00;
                        jal_o <= 1'b0;
                        illegal_instr_o <= 1'b0;
                        mem_we_o <= 1'b0;
                        gpr_we_a_o <= 1'b0;
                        INT_RST <= 1'b0;
                        csr <= 1'b0;
                        CSRop <= 3'b0;
                        INT_RST <= 1'b0;
                        case ( fetched_instr_i[6:2] )
                            `LOAD_OPCODE: begin
                                             mem_req_o <= 1'b1;
                                             ex_op_a_sel_o <= 2'b00;
                                             ex_op_b_sel_o <= 3'b001;
                                             wb_src_sel_o <= 1'b1;
                                             alu_op_o <= `ALU_ADD;
                                             gpr_we_a_o <= 1'b1;
                                             case ( fetched_instr_i[14:12] )
                                                3'h0: 
                                                   mem_size_o <= 3'h0;
                                                3'h1:
                                                   mem_size_o <= 3'h1;
                                                3'h2:
                                                   mem_size_o <= 3'h2;
                                                3'h4:
                                                   mem_size_o <= 3'h4;
                                                3'h5:
                                                   mem_size_o <= 3'h5;
                                                default:
                                                   illegal_instr_o <= 1'b1;
                                             endcase
                                          end                        
                            `MISC_MEM_OPCODE: begin
                                                 jalr_o <= 2'b0;
                                                 csr <= 1'b0;
                                                 illegal_instr_o <= 1'b0;
                                                 wb_src_sel_o <= 1'b0;
                                                 ex_op_a_sel_o <= 2'b0;
                                                 ex_op_b_sel_o <= 3'b0;
                                                 alu_op_o <= 5'b0;
                                                 mem_req_o <= 1'b0;
                                                 mem_we_o <= 1'b0;
                                                 mem_size_o <= 3'b0;
                                                 gpr_we_a_o <= 1'b0;
                                                 branch_o <= 1'b0;
                                                 jal_o <= 1'b0;
                                                 csr <= 1'b0;    
                                                 CSRop <= 3'b0;  
                                                 INT_RST <= 1'b0;
                                              end
                            `OP_IMM_OPCODE: begin
                                               ex_op_a_sel_o <= 2'b00;
                                               ex_op_b_sel_o <= 3'b001;
                                               gpr_we_a_o <= 1'b1;
                                               wb_src_sel_o <= 1'b0;
                                               case ( fetched_instr_i[14:12] )
                                                  3'h0: begin
                                                           alu_op_o <= `ALU_ADD;
                                                        end
                                                  3'h4: begin
                                                           alu_op_o <= `ALU_XOR;
                                                        end
                                                  3'h6: begin
                                                           alu_op_o <= `ALU_OR;
                                                        end
                                                  3'h7: begin
                                                           alu_op_o <= `ALU_AND;
                                                        end
                                                  3'h1: begin
                                                           case ( fetched_instr_i[31:25] )
                                                               7'h0: begin
                                                                        alu_op_o <= `ALU_SLL;
                                                                     end
                                                               default:
                                                                  illegal_instr_o <= 1'b1;
                                                           endcase
                                                        end
                                                  3'h5: begin
                                                           case ( fetched_instr_i[31:25] )
                                                              7'h0: begin
                                                                       alu_op_o <= `ALU_SRL;
                                                                    end
                                                              7'h20: begin
                                                                        alu_op_o <= `ALU_SRA;
                                                                     end
                                                              default:
                                                                 illegal_instr_o <= 1'b1;
                                                           endcase
                                                        end
                                                  3'h2: begin
                                                           alu_op_o <= `ALU_SLTS;
                                                        end
                                                  3'h3: begin
                                                           alu_op_o <= `ALU_SLTU;
                                                        end
                                                  default:
                                                     illegal_instr_o <= 1'b1;
                                               endcase
                                            end
                            `AUIPC_OPCODE: begin
                                              gpr_we_a_o <= 1'b1;
                                              ex_op_a_sel_o <= 2'b01;
                                              ex_op_b_sel_o <= 3'b010;
                                              alu_op_o <= `ALU_ADD;
                                              wb_src_sel_o <= 1'b0;
                                           end
                            `STORE_OPCODE: begin
                                              gpr_we_a_o <= 1'b0;
                                              ex_op_a_sel_o <= 2'b00;
                                              ex_op_b_sel_o <= 3'b011;
                                              alu_op_o <= `ALU_ADD;
                                              mem_we_o <= 1'b1;
                                              mem_req_o <= 1'b1;
                                              case ( fetched_instr_i[14:12] )
                                                 3'h0:
                                                    mem_size_o <= 3'h0;
                                                 3'h1:
                                                    mem_size_o <= 3'h1;
                                                 3'h2:
                                                    mem_size_o <= 3'h2;
                                                 default:
                                                    illegal_instr_o <= 1'b1;
                                              endcase
                                           end
                            `OP_OPCODE: begin
                                           gpr_we_a_o <= 1'b1;
                                           wb_src_sel_o <= 1'b0;
                                           ex_op_a_sel_o <= 2'b00;
                                           ex_op_b_sel_o <= 3'b000;
                                           case ( fetched_instr_i[14:12] )
                                              3'h0: begin
                                                       case ( fetched_instr_i[31:25] )
                                                          7'h0:
                                                             alu_op_o <= `ALU_ADD;
                                                          7'h20:
                                                             alu_op_o <= `ALU_SUB;
                                                          default:
                                                             illegal_instr_o <= 1'b1;
                                                       endcase
                                                    end
                                              3'h4: begin
                                                       case ( fetched_instr_i[31:25] )
                                                          7'h0:
                                                             alu_op_o <= `ALU_XOR;
                                                          default:
                                                             illegal_instr_o <= 1'b1;
                                                       endcase
                                                    end
                                              3'h6: begin
                                                       case ( fetched_instr_i[31:25] )
                                                          7'h0:
                                                             alu_op_o <= `ALU_OR;
                                                          default:
                                                             illegal_instr_o <= 1'b1;
                                                       endcase
                                                    end
                                              3'h7: begin
                                                       case ( fetched_instr_i[31:25] )
                                                          7'h0:
                                                             alu_op_o <= `ALU_AND;
                                                          default:
                                                             illegal_instr_o <= 1'b1;
                                                       endcase
                                                    end
                                              3'h1: begin
                                                       case ( fetched_instr_i[31:25] )
                                                          7'h0:
                                                             alu_op_o <= `ALU_SLL;
                                                          default:
                                                             illegal_instr_o <= 1'b1;
                                                       endcase
                                                    end
                                              3'h5: begin
                                                       case ( fetched_instr_i[31:25] )
                                                          7'h0:
                                                             alu_op_o <= `ALU_SRL;
                                                          7'h20:
                                                             alu_op_o <= `ALU_SRA;
                                                          default:
                                                             illegal_instr_o <= 1'b1;
                                                       endcase
                                                    end
                                              3'h2: begin
                                                       case ( fetched_instr_i[31:25] )
                                                          7'h0:
                                                             alu_op_o <= `ALU_SLTS;
                                                          default:
                                                             illegal_instr_o <= 1'b1;
                                                       endcase
                                                    end
                                              3'h3: begin
                                                       case ( fetched_instr_i[31:25] )
                                                          7'h0:
                                                             alu_op_o <= `ALU_SLTU;
                                                          default:
                                                             illegal_instr_o <= 1'b1;
                                                       endcase
                                                    end
                                              default:
                                                 illegal_instr_o <= 1'b1;
                                           endcase
                                        end
                            `LUI_OPCODE: begin
                                            gpr_we_a_o <= 1'b1;
                                            ex_op_a_sel_o <= 2'b10;
                                            ex_op_b_sel_o <= 3'b010;
                                            alu_op_o <= `ALU_ADD;
                                            wb_src_sel_o <= 1'b0;
                                         end
                            `BRANCH_OPCODE: begin
                                               branch_o <= 1'b1;
                                               gpr_we_a_o <= 1'b0;
                                               ex_op_a_sel_o <= 2'b00;
                                               ex_op_b_sel_o <= 3'b000;
                                               mem_we_o <= 1'b0;
                                               mem_req_o <= 1'b0;
                                               mem_size_o <= 3'h0;
                                               case ( fetched_instr_i[14:12] )
                                                  3'h0: begin
                                                           alu_op_o <= `ALU_EQ;
                                                        end
                                                  3'h1: begin
                                                           alu_op_o <= `ALU_NE;
                                                        end
                                                  3'h4: begin
                                                           alu_op_o <= `ALU_LTS;
                                                        end
                                                  3'h5: begin
                                                           alu_op_o <= `ALU_GES;
                                                        end
                                                  3'h6: begin
                                                           alu_op_o <= `ALU_LTU;
                                                        end
                                                  3'h7: begin
                                                           alu_op_o <= `ALU_GEU;
                                                        end
                                                  default:
                                                     illegal_instr_o <= 1'b1;
                                               endcase
                                            end
                            `JALR_OPCODE: begin
                                             case ( fetched_instr_i[14:12] )
                                                3'h0: begin
                                                         jalr_o <= 2'b01;
                                                         gpr_we_a_o <= 1'b1;
                                                         ex_op_a_sel_o <= 2'b01;
                                                         ex_op_b_sel_o <= 3'b100;
                                                         alu_op_o <= `ALU_ADD;
                                                         wb_src_sel_o <= 1'b0;
                                                      end
                                                default:
                                                   illegal_instr_o <= 1'b1;
                                             endcase
                                          end
                            `JAL_OPCODE: begin
                                            jal_o <= 1'b1;
                                            branch_o <= 1'b0;
                                            gpr_we_a_o <= 1'b1;
                                            ex_op_a_sel_o <= 2'b01;
                                            ex_op_b_sel_o <= 3'b100;
                                            alu_op_o <= `ALU_ADD;
                                            wb_src_sel_o <= 1'b0;
                                         end
                            `SYSTEM_OPCODE: begin
                                                wb_src_sel_o <= 1'b0;      
                                                mem_req_o <= 1'b0;     
                                                mem_we_o <= 3'b0;      
                                                mem_size_o <= 3'b0;    
                                                branch_o <= 1'b0;
                                                illegal_instr_o <= 1'b0;
                                                alu_op_o <= 5'b0;
                                                ex_op_a_sel_o <= 2'b00;
                                                ex_op_b_sel_o <= 3'b0;
                                                CSRop <= fetched_instr_i[14:12];
                                                case ( fetched_instr_i[14:12] )
                                                    3'b000: begin
                                                                gpr_we_a_o <= 1'b0;
                                                                csr <= 1'b0;
                                                                jalr_o <= 2'b10;
                                                                INT_RST <= 1'b1;
                                                            end
                                                    3'b001: begin
                                                                gpr_we_a_o <= 1'b1;
                                                                csr <= 1'b1;
                                                                jalr_o <= 2'b0;
                                                                INT_RST <= 1'b0;
                                                            end
                                                    3'b010: begin
                                                                gpr_we_a_o <= 1'b1;
                                                                csr <= 1'b1;
                                                                jalr_o <= 2'b0;
                                                                INT_RST <= 1'b0;
                                                            end
                                                    3'b011: begin
                                                                gpr_we_a_o <= 1'b1;
                                                                csr <= 1'b1;
                                                                jalr_o <= 2'b0;
                                                                INT_RST <= 1'b0;
                                                            end
                                                    default: begin
                                                                jalr_o <= 2'b0;
                                                                csr <= 1'b0;
                                                                illegal_instr_o <= 1'b1;
                                                                wb_src_sel_o <= 1'b0;
                                                                ex_op_a_sel_o <= 2'b0;
                                                                ex_op_b_sel_o <= 3'b0;
                                                                alu_op_o <= 5'b0;
                                                                mem_req_o <= 1'b0;
                                                                mem_we_o <= 1'b0;
                                                                mem_size_o <= 3'b0;
                                                                gpr_we_a_o <= 1'b0;
                                                                branch_o <= 1'b0;
                                                                jal_o <= 1'b0;
                                                                csr <= 1'b0;    
                                                                CSRop <= 3'b0;  
                                                                INT_RST <= 1'b0;
                                                             end
                                                endcase
                                            end
                            default: begin
                                    illegal_instr_o <= 1'b1;
                                    ex_op_a_sel_o <= 2'b0;
                                    ex_op_b_sel_o <= 3'b0;
                                    alu_op_o <= 5'b0;
                                    mem_req_o <= 1'b0;
                                    mem_we_o <= 1'b0;
                                    mem_size_o <= 3'b0;
                                    gpr_we_a_o <= 1'b0;
                                    wb_src_sel_o <= 1'b0;
                                    branch_o <= 1'b0;
                                    jal_o <= 1'b0;
                                    jalr_o <= 2'b00;
                                    INT_RST <= 1'b0;
                                    csr <= 1'b0;
                                    CSRop <= 3'b0;
                                    INT_RST <= 1'b0;
                                end
                        endcase
                   end
            default: begin
                        illegal_instr_o <= 1'b1;
                        ex_op_a_sel_o <= 2'b0;
                        ex_op_b_sel_o <= 3'b0;
                        alu_op_o <= 5'b0;
                        mem_req_o <= 1'b0;
                        mem_we_o <= 1'b0;
                        mem_size_o <= 3'b0;
                        gpr_we_a_o <= 1'b0;
                        wb_src_sel_o <= 1'b0;
                        branch_o <= 1'b0;
                        jal_o <= 1'b0;
                        jalr_o <= 2'b00;
                        INT_RST <= 1'b0;
                        csr <= 1'b0;
                        CSRop <= 3'b0;
                        INT_RST <= 1'b0;
                     end
        endcase
    end
end

endmodule
