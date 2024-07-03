`timescale 1ns / 1ps

module miriscv_lsu(
                   input             clk_i, // синхронизация
                   input             arstn_i, // сброс внутренних регистров
                   // core protocol
                   input      [31:0] lsu_addr_i, // адрес, по которому хотим обратиться
                   input             lsu_we_i, // 1 - если нужно записать в память
                   input      [2:0]  lsu_size_i, // размер обрабатываемых данных
                   input      [31:0] lsu_data_i, // данные для записи в память
                   input             lsu_req_i, // 1 - обратиться к памяти
                   output reg        lsu_stall_req_o, // используется как !enable pc
                   output reg [31:0] lsu_data_o, // данные считанные из памяти
                   // memory protocol
                   input      [31:0] data_rdata_i, // запрошенные данные
                   output            data_req_o, // 1 - обратиться к памяти
                   output            data_we_o, // 1 - это запрос на запись
                   output reg [3:0]  data_be_o, // к каким байтам слова идет обращение
                   output     [31:0] data_addr_o, // адрес, по которому идет обращение
                   output reg [31:0] data_wdata_o // данные, которые требуется записать
    );

assign data_addr_o = lsu_addr_i;

assign data_req_o  = lsu_stall_req_o;

assign data_we_o   = (lsu_we_i) ? lsu_stall_req_o : 1'b0;

reg stall_buff = 1'b1;
always @(posedge clk_i or negedge arstn_i)
    begin
    if (!arstn_i || !stall_buff)
        stall_buff <= 1'b1;
    else
        stall_buff <= !lsu_req_i;
end 
        
always @(*)
    lsu_stall_req_o <= stall_buff & lsu_req_i; 

always @( * )
begin
//    if ( !arstn_i ) begin
//        lsu_data_o <= 32'b0;
//        data_be_o <= 4'b0;
 //       data_wdata_o <= 32'b0;
   // end else begin
    lsu_data_o <= 32'b0;
    data_be_o <= 4'b0;
    data_wdata_o <= 32'b0;
    if ( lsu_req_i ) begin
        case ( lsu_size_i )
            3'b000: begin
                if ( lsu_we_i )
                    data_wdata_o <= {4{lsu_data_i[7:0]}};
                case ( lsu_addr_i[1:0] )
                    2'b00: begin
                        lsu_data_o <= {{24{data_rdata_i[7]}}, data_rdata_i[7:0]};
                        data_be_o <= 4'b0001;
                    end
                    2'b01: begin
                        lsu_data_o <= {{24{data_rdata_i[15]}}, data_rdata_i[15:8]};
                        data_be_o <= 4'b0010;
                    end
                    2'b10:begin
                        lsu_data_o <= {{24{data_rdata_i[23]}}, data_rdata_i[23:16]};
                        data_be_o <= 4'b0100;
                    end
                    2'b11: begin
                        lsu_data_o <= {{24{data_rdata_i[31]}}, data_rdata_i[31:24]};
                        data_be_o <= 4'b1000;
                    end
                    default: begin
                        lsu_data_o <= 32'b0;
                        data_be_o <= 4'b0;
                    end
                endcase
            end
            3'b001: begin
                if ( lsu_we_i )
                    data_wdata_o <= {2{lsu_data_i[15:0]}};
                case ( lsu_addr_i[1:0] )
                    2'b00: begin
                        lsu_data_o <= {{16{data_rdata_i[15]}}, data_rdata_i[15:0]};
                        data_be_o <= 4'b0011;
                    end
                    2'b10: begin
                        lsu_data_o <= {{16{data_rdata_i[31]}}, data_rdata_i[31:16]};
                        data_be_o <= 4'b1100;
                    end
                    default: begin
                        lsu_data_o <= 32'b0;
                        data_be_o <= 4'b0;
                    end
                endcase
            end
            3'b010: begin
                if ( lsu_we_i )
                    data_wdata_o <= lsu_data_i;
                if ( lsu_addr_i[1:0] == 2'b00 ) begin
                    lsu_data_o <= data_rdata_i;
                    data_be_o <= 4'b1111;
                end
                else begin
                    lsu_data_o <= 32'b0;
                    data_be_o <= 4'b0;
                end
            end
            3'b100: begin
                case ( lsu_addr_i[1:0] )
                    2'b00: begin
                        lsu_data_o <= {24'b0, data_rdata_i[7:0]};
                    end
                    2'b01: begin
                        lsu_data_o <= {24'b0, data_rdata_i[15:8]};
                    end
                    2'b10: begin
                        lsu_data_o <= {24'b0, data_rdata_i[23:16]};
                    end
                    2'b11: begin
                        lsu_data_o <= {24'b0, data_rdata_i[31:24]};
                    end
                    default: begin
                        lsu_data_o <= 32'b0;
                    end
                endcase
            end
            3'b101: begin
                case ( lsu_addr_i[1:0] )
                    2'b00: begin
                        lsu_data_o <= {16'b0, data_rdata_i[15:0]};
                    end
                    2'b10: begin
                        lsu_data_o <= {16'b0, data_rdata_i[31:16]};
                    end
                    default: begin
                        lsu_data_o <= 32'b0;
                    end
                endcase
            end
            default:
                lsu_data_o <= 32'b0;
        endcase
    end
   // end
end

endmodule
