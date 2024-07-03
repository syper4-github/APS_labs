`timescale 1ns / 1ps

module miriscv_top
#(
  parameter RAM_SIZE      = 4096, // bytes
  parameter RAM_INIT_FILE = "Instructions.txt"
)
(
  // clock, reset
  input         clk_100M,
  input         rst_n_i,
  //input  [31:0] int_req_ic,
  //output [31:0] int_fin_ic,
  input  [15:0] sw_i,
  output [15:0] led_o
);
  //logic [31:0] PC;
  //assign led_o = PC[15:0];
  logic clk_i = 1'b0;
  always @(posedge clk_100M)
    clk_i <= ~clk_i;
  logic  [31:0]  instr_rdata_core;
  logic  [31:0]  instr_addr_core;

  logic  [31:0]  data_rdata_core;
  logic          data_req_core;
  logic          data_we_core;
  logic  [3:0]   data_be_core;
  logic  [31:0]  data_addr_core;
  logic  [31:0]  data_wdata_core;

  logic  [31:0]  data_rdata_ram;
  logic          data_req_ram;
  logic          data_we_ram;
  logic  [3:0]   data_be_ram;
  logic  [31:0]  data_addr_ram;
  logic  [31:0]  data_wdata_ram;

  logic INT_RST_ic;
  logic INT_RST_core;
  assign INT_RST_ic = INT_RST_core;
  
  logic INT_core;
  logic INT_ic;
  assign INT_core = INT_ic;
  
  logic [31:0] mie_core;
  logic [31:0] mie_ic;
  assign mie_ic = mie_core;
  
  logic [31:0] mcause_core;
  logic [31:0] mcause_ic;
  assign mcause_core = mcause_ic;

  logic  data_mem_valid;
  assign data_mem_valid = (data_addr_core >= RAM_SIZE) ?  1'b0 : 1'b1;

  //assign data_rdata_core  = (data_mem_valid) ? data_rdata_ram : 1'b0;
  assign data_req_ram     = (data_mem_valid) ? data_req_core : 1'b0;
  assign data_we_ram      =  data_we_core;
  assign data_be_ram      =  data_be_core;
  assign data_addr_ram    =  data_addr_core;
  assign data_wdata_ram   =  data_wdata_core;
//
  logic [31:0] int_req_ic;
  initial      int_req_ic = 32'b0;
  logic        int_req_swc_o;

  assign int_req_ic = {{26{1'b0}}, int_req_swc_o, {5{1'b0}}};
  
  logic [31:0] int_fin_ic;
  logic int_fin_sw;
  assign int_fin_sw = int_fin_ic[5];

  logic d0_i;
  //logic d1_i;
  logic d0_o;
  //logic d1_o;
  assign d0_i = d0_o;
  //assign d1_i = d1_o;

  logic we_m_i;
  logic req_m_i;
  logic we_m_o;
  logic req_m_o;
  assign we_m_i = we_m_o;
  assign req_m_i = req_m_o;
  
  logic [1:0] RDsel;
  logic [31:0] data_rdata_sw;
  logic [31:0] data_rdata_led;
  always_comb
     case(RDsel)
        2'b00:
            data_rdata_core = (data_mem_valid) ? data_rdata_ram : 1'b0;
        2'b01:
            data_rdata_core = data_rdata_led;
        2'b10:
            data_rdata_core = data_rdata_sw;
        default:
            data_rdata_core = 0;
     endcase
  
  //logic [15:0] sw_controller_i;
  //assign sw_controller_i = sw_i;
  
//
  miriscv_core core (
    .clk_i   ( clk_i   ),
    .arstn_i ( rst_n_i ),

    .instr_rdata_i ( instr_rdata_core ),
    .instr_addr_o  ( instr_addr_core  ),

    .data_rdata_i  ( data_rdata_core  ),
    .data_req_o    ( data_req_core    ),
    .data_we_o     ( data_we_core     ),
    .data_be_o     ( data_be_core     ),
    .data_addr_o   ( data_addr_core   ),
    .data_wdata_o  ( data_wdata_core  ),
    .INT           ( INT_core         ),
    .INT_RST       ( INT_RST_core     ),
    .mcause        ( mcause_core      ),
    .mie           ( mie_core         )
    //.PC            ( PC               )
  );

  miriscv_ram
  #(
    .RAM_SIZE      (RAM_SIZE),
    .RAM_INIT_FILE (RAM_INIT_FILE)
  ) ram (
    .clk_i   ( clk_i   ),
    .rst_n_i ( rst_n_i ),

    .instr_rdata_o ( instr_rdata_core ),
    .instr_addr_i  ( instr_addr_core  ),

    .data_rdata_o  ( data_rdata_ram  ),
    .data_req_i    ( data_req_ram    ),
    .data_we_i     ( data_we_ram     ),
    .data_be_i     ( data_be_ram     ),
    .data_addr_i   ( data_addr_ram   ),
    .data_wdata_i  ( data_wdata_ram  )
  );

IC IC (
    .clk           ( clk_i           ),
    .INT_RST       ( INT_RST_ic      ),
    .mie           ( mie_ic          ),
    .int_req       ( int_req_ic      ),
    .mcause        ( mcause_ic       ),
    .int_fin       ( int_fin_ic      ),
    .INT           ( INT_ic          )
);

AddressDecoder AD (
    .addr          ( data_addr_ram   ),
    .we            ( data_we_core    ),
    .req           ( data_req_core   ),
    .we_m          ( we_m_o          ),
    .req_m         ( req_m_o         ),
    .we_d0         ( d0_o            ),
    //.we_d1         ( d1_o            ),
    .RDsel         ( RDsel           )
);

Controller_Led LED(
    .clk           ( clk_i           ),     
    //.led_address   ( data_addr_ram   ),
    .led_wdata     ( data_wdata_ram  ),
    .we_d0         ( d0_i            ),
    .be_d0         ( data_be_ram     ),
    .rdata         ( data_rdata_led  ),
    .led_reg       ( led_o           )
);

Controller_Switch SW(
    .clk           ( clk_i           ),
    //.sw_address    ( data_addr_ram   ),
    .sw_16         ( sw_i            ),
    .int_fin_sw_i  ( int_fin_sw      ),
    .int_req_sw_o  ( int_req_swc_o   ),
    //.we_d1         ( d1_i            ),
    .rdata         ( data_rdata_sw   )
);

endmodule