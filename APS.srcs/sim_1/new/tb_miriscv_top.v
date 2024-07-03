`timescale 1ns / 1ps

module tb_miriscv_top();

  parameter     HF_CYCLE = 2.5;       // 200 MHz clock
  parameter     RST_WAIT = 10;         // 10 ns reset
  parameter     RAM_SIZE = 4096;       // in 32-bit words

  // clock, reset
  reg clk;
  reg rst_n;
  
  // added for tb
  wire [31:0] register1;
  wire [31:0] register2;
  wire [31:0] register21;
  wire [31:0] register_t2;
  wire [31:0] instr_rdata_core;
  wire [31:0] instr_addr_core;
  wire [31:0] lsu_addr_i;
  wire [31:0] lsu_data_i;
  wire [2:0] lsu_size_i;
  wire [31:0] lsu_data_o;
  wire lsu_stall_req_o;
  wire [31:0]  data_rdata_core;
  wire         data_req_core;
  wire         data_we_core;
  wire [3:0]   data_be_core;
  wire [31:0]  data_addr_core;
  wire [31:0]  data_wdata_core;
  wire en_pc;
  wire [1:0] jalr_o;
  wire [31:0] int_req;
  wire [31:0] int_fin;
  reg [15:0] SW;
  wire [15:0] LED;
  wire [5:0] i_from_ic;
  wire [31:0] mcause_ic;
  wire [31:0] mtvec_core;
  wire [31:0] mepc_core;
  wire INT_RST_ic;
  wire [31:0] data_from_SW;
  wire [1:0] RDsel;
  miriscv_top #(
    .RAM_SIZE       ( RAM_SIZE           ),
    .RAM_INIT_FILE  ( "Instructions.txt" )
  ) dut (
    .clk_100M    ( clk   ),
    .rst_n_i  ( rst_n ),
    .sw_i     ( SW    ),
    .led_o    ( LED   )
    //.int_req_ic ( int_req )
    //.int_fin_ic ( int_fin )
    
    // added for tb
    //.register1(register1),
    //.register2(register2),
    //.instr_rdata_core(instr_rdata_core),
    //.instr_addr_core(instr_addr_core),
    //.lsu_req_i(lsu_req_i),
    //.lsu_we_i(lsu_we_i),
    //.lsu_addr_i(lsu_addr_i),
    //.lsu_data_i(lsu_data_i),
    //.lsu_size_i(lsu_size_i),
    //.lsu_data_o(lsu_data_o),
    //.lsu_stall_req_o(lsu_stall_req_o),
    //.data_rdata_core(data_rdata_core),
    //.data_req_core(data_req_core),
    //.data_we_core(data_we_core),
    //.data_be_core(data_be_core),
    //.data_addr_core(data_addr_core),
    //.data_wdata_core(data_wdata_core)
  );


   assign register1 = RF.RAM[1];
   assign register2 = RF.RAM[2];
   assign register21 = RF.RAM[21];
   assign instr_rdata_core = miriscv_core.instr_rdata_i;
   assign instr_addr_core = miriscv_core.instr_addr_o;
   assign lsu_req_i = miriscv_lsu.lsu_req_i;
   assign lsu_we_i = miriscv_lsu.lsu_we_i;
   assign lsu_addr_i = miriscv_lsu.lsu_addr_i;
   assign lsu_data_i = RF.rd2;
   assign lsu_size_i = miriscv_lsu.lsu_size_i;
   assign lsu_data_o = miriscv_lsu.lsu_data_o;
   assign lsu_stall_req_o = miriscv_lsu.lsu_stall_req_o;
   assign data_rdata_core = miriscv_core.data_rdata_i;
   assign data_req_core = miriscv_core.data_req_o;
   assign data_we_core = miriscv_core.data_we_o;
   assign data_be_core = miriscv_core.data_be_o;
   assign data_addr_core = miriscv_core.data_addr_o;
   assign data_wdata_core = miriscv_core.data_wdata_o;
   assign en_pc = miriscv_core.en_pc;
   assign jalr_o = miriscv_core.jalr_o;
   assign i_from_ic = IC.i;
   assign mcause_ic = IC.mcause;
   assign mtvec_core = miriscv_core.mtvec;
   assign mepc_core = miriscv_core.mepc;
   assign INT_RST_ic = IC.INT_RST;
   assign register_t2 = RF.RAM[7];
   assign int_req = miriscv_top.int_req_ic;
   assign int_fin = miriscv_top.int_fin_ic;
   assign data_from_SW = miriscv_top.data_rdata_sw;
   assign RDsel = miriscv_top.RDsel;
  initial begin
    clk   = 1'b0;
    rst_n = 1'b0;
    #RST_WAIT;
    rst_n = 1'b1;
    #150;
    //int_req = 32'b00000000000000000000000000100000;
    #150;
    //int_req = 32'b00000000000000000000000000000000;
    SW = 16'b100;
    #200;
    //int_req = 32'b00000000000010000000000000000000;
    #200;
    //int_req = 32'b00000000000000000000000000000000;
    SW = 16'b1100;
    //#600
    //rst_n = 1'b0;
    //#RST_WAIT
    //rst_n = 1'b1;
  end

  always begin
    #HF_CYCLE;
    clk = ~clk;
  end

endmodule