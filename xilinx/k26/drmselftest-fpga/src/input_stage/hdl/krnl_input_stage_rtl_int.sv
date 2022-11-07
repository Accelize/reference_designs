// /*******************************************************************************
// Copyright (c) 2019, Xilinx, Inc.
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1. Redistributions of source code must retain the above copyright notice,
// this list of conditions and the following disclaimer.
// 
// 
// 2. Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
// 
// 
// 3. Neither the name of the copyright holder nor the names of its contributors
// may be used to endorse or promote products derived from this software
// without specific prior written permission.
// 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,THE IMPLIED 
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY 
// OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
// EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// *******************************************************************************/

///////////////////////////////////////////////////////////////////////////////
// Description: This is a example of how to create an RTL Kernel with pipe. 
// This module is an input stage which will perform AXI4 reads, buffer the read
// data and then output the data over an AXI4-Stream (pipe.)
//
// Data flow: axi_read_master->fifo->pipe axi4-stream output
///////////////////////////////////////////////////////////////////////////////

// default_nettype of none prevents implicit wire declaration.
`default_nettype none
`timescale 1 ns / 1 ps 

module krnl_input_stage_rtl_int #( 
  parameter integer  C_S_AXI_CONTROL_DATA_WIDTH = 32,
  parameter integer  C_S_AXI_CONTROL_ADDR_WIDTH = 6,
  parameter integer  C_M_AXI_GMEM_ADDR_WIDTH = 64,
  parameter integer  C_M_AXI_GMEM_DATA_WIDTH = 32
)
(
  // System signals
  input  wire                                 ap_clk,
  input  wire                                 ap_rst_n,
  // AXI4 master interface 
  input  wire                                 m_axi_gmem_AWREADY,
  output wire                                 m_axi_gmem_AWVALID,
  output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_AWADDR,
  output wire [7:0]                           m_axi_gmem_AWLEN,
  input  wire                                 m_axi_gmem_WREADY,
  output wire                                 m_axi_gmem_WVALID,
  output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_WDATA,
  output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_WSTRB,
  output wire                                 m_axi_gmem_WLAST,
  output wire                                 m_axi_gmem_BREADY,
  input  wire                                 m_axi_gmem_BVALID,
  input  wire [1:0]                           m_axi_gmem_BRESP,
  input  wire                                 m_axi_gmem_ARREADY,
  output wire                                 m_axi_gmem_ARVALID,
  output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_ARADDR,
  output wire [7:0]                           m_axi_gmem_ARLEN,
  output wire                                 m_axi_gmem_RREADY,
  input  wire                                 m_axi_gmem_RVALID,
  input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_RDATA,
  input  wire                                 m_axi_gmem_RLAST,
  input  wire [1:0]                           m_axi_gmem_RRESP,
  // AXI4-Stream master interface
  input  wire                                 p0_TREADY,
  output wire                                 p0_TVALID,
  output wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] p0_TDATA,
  // AXI4-Lite slave interface
  output wire                                    s_axi_control_AWREADY,
  input  wire                                    s_axi_control_AWVALID,
  input  wire [C_S_AXI_CONTROL_ADDR_WIDTH-1:0]   s_axi_control_AWADDR,
  output wire                                    s_axi_control_WREADY,
  input  wire                                    s_axi_control_WVALID,
  input  wire [C_S_AXI_CONTROL_DATA_WIDTH-1:0]   s_axi_control_WDATA,
  input  wire [C_S_AXI_CONTROL_DATA_WIDTH/8-1:0] s_axi_control_WSTRB,
  input  wire                                    s_axi_control_BREADY,
  output wire                                    s_axi_control_BVALID,
  output wire [1:0]                              s_axi_control_BRESP,
  output wire                                    s_axi_control_ARREADY,
  input  wire                                    s_axi_control_ARVALID,
  input  wire [C_S_AXI_CONTROL_ADDR_WIDTH-1:0]   s_axi_control_ARADDR,
  input  wire                                    s_axi_control_RREADY,
  output wire                                    s_axi_control_RVALID,
  output wire [C_S_AXI_CONTROL_DATA_WIDTH-1:0]   s_axi_control_RDATA,
  output wire [1:0]                              s_axi_control_RRESP,
  output wire                                    interrupt 
);
///////////////////////////////////////////////////////////////////////////////
// Local Parameters (constants)
///////////////////////////////////////////////////////////////////////////////
localparam integer LP_NUM_READ_CHANNELS  = 1;
localparam integer LP_LENGTH_WIDTH       = 32;
localparam integer LP_DW_BYTES           = C_M_AXI_GMEM_DATA_WIDTH/8;
localparam integer LP_AXI_BURST_LEN      = 4096/LP_DW_BYTES < 256 ? 4096/LP_DW_BYTES : 256;
localparam integer LP_LOG_BURST_LEN      = $clog2(LP_AXI_BURST_LEN);
localparam integer LP_RD_MAX_OUTSTANDING = 3;
localparam integer LP_RD_FIFO_DEPTH      = LP_AXI_BURST_LEN*(LP_RD_MAX_OUTSTANDING + 1);


///////////////////////////////////////////////////////////////////////////////
// Variables
///////////////////////////////////////////////////////////////////////////////
logic areset = 1'b0;  
logic ap_start;
logic ap_start_pulse;
logic ap_start_r;
logic ap_ready;
logic ap_done;
logic ap_idle = 1'b1;
logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] ctrl_offset;
logic [LP_LENGTH_WIDTH-1:0]         ctrl_length;
logic done = 1'b0;

logic read_done;
logic [LP_NUM_READ_CHANNELS-1:0] rd_tvalid;
logic [LP_NUM_READ_CHANNELS-1:0] rd_tready_n; 
logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata;
logic [LP_NUM_READ_CHANNELS-1:0] ctrl_rd_fifo_prog_full;
logic [LP_NUM_READ_CHANNELS-1:0] rd_fifo_tvalid_n;
logic [LP_NUM_READ_CHANNELS-1:0] rd_fifo_tready; 
logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_fifo_tdata;

///////////////////////////////////////////////////////////////////////////////
// RTL Logic 
///////////////////////////////////////////////////////////////////////////////
// Tie-off unused AXI protocol features
assign m_axi_gmem_AWVALID  = 1'b0;
assign m_axi_gmem_AWADDR   = {C_M_AXI_GMEM_ADDR_WIDTH{1'b0}};
assign m_axi_gmem_AWLEN    = 8'b00;
assign m_axi_gmem_WVALID   = 1'b0;
assign m_axi_gmem_WDATA    = {C_M_AXI_GMEM_DATA_WIDTH{1'b0}};
assign m_axi_gmem_WSTRB    = {C_M_AXI_GMEM_DATA_WIDTH/8{1'b0}};
assign m_axi_gmem_WLAST    = 1'b0;
assign m_axi_gmem_BREADY   = 1'b0;

// Register and invert reset signal for better timing.
always @(posedge ap_clk) begin 
  areset <= ~ap_rst_n; 
end

// create pulse when ap_start transitions to 1
always @(posedge ap_clk) begin 
  begin 
    ap_start_r <= ap_start;
  end
end

assign ap_start_pulse = ap_start & ~ap_start_r;

// ap_idle is asserted when done is asserted, it is de-asserted when ap_start_pulse 
// is asserted
always @(posedge ap_clk) begin 
  if (areset) begin 
    ap_idle <= 1'b1;
  end
  else begin 
    ap_idle <= ap_done        ? 1'b1 : 
               ap_start_pulse ? 1'b0 : 
                                ap_idle;
  end
end

assign ap_ready = ap_done;

always @(posedge ap_clk) begin 
  if (areset) begin 
    done <= 1'b0;
  end
  else begin 
    done <= read_done ? 1'b1 : 
            ap_done   ? 1'b0 :
                        done ;
  end
end

assign ap_done = done & rd_fifo_tvalid_n;

// AXI4-Lite slave
krnl_input_stage_rtl_control_s_axi #(
  .C_S_AXI_ADDR_WIDTH( C_S_AXI_CONTROL_ADDR_WIDTH ),
  .C_S_AXI_DATA_WIDTH( C_S_AXI_CONTROL_DATA_WIDTH )
) 
inst_krnl_input_stage_control_s_axi (
  .AWVALID   ( s_axi_control_AWVALID                   ) ,
  .AWREADY   ( s_axi_control_AWREADY                   ) ,
  .AWADDR    ( s_axi_control_AWADDR                    ) ,
  .WVALID    ( s_axi_control_WVALID                    ) ,
  .WREADY    ( s_axi_control_WREADY                    ) ,
  .WDATA     ( s_axi_control_WDATA                     ) ,
  .WSTRB     ( s_axi_control_WSTRB                     ) ,
  .ARVALID   ( s_axi_control_ARVALID                   ) ,
  .ARREADY   ( s_axi_control_ARREADY                   ) ,
  .ARADDR    ( s_axi_control_ARADDR                    ) ,
  .RVALID    ( s_axi_control_RVALID                    ) ,
  .RREADY    ( s_axi_control_RREADY                    ) ,
  .RDATA     ( s_axi_control_RDATA                     ) ,
  .RRESP     ( s_axi_control_RRESP                     ) ,
  .BVALID    ( s_axi_control_BVALID                    ) ,
  .BREADY    ( s_axi_control_BREADY                    ) ,
  .BRESP     ( s_axi_control_BRESP                     ) ,
  .ACLK      ( ap_clk                                  ) ,
  .ARESET    ( areset                                  ) ,
  .ACLK_EN   ( 1'b1                                    ) ,
  .ap_start  ( ap_start                                ) ,
  .interrupt ( interrupt                               ) ,
  .ap_ready  ( ap_ready                                ) ,
  .ap_done   ( ap_done                                 ) ,
  .ap_idle   ( ap_idle                                 ) ,
  .input_r   ( ctrl_offset[0+:C_M_AXI_GMEM_ADDR_WIDTH] ) ,
  .size      ( ctrl_length[0+:LP_LENGTH_WIDTH]         )
);

// AXI4 Read Master
krnl_input_stage_rtl_axi_read_master #( 
  .C_ADDR_WIDTH       ( C_M_AXI_GMEM_ADDR_WIDTH ) ,
  .C_DATA_WIDTH       ( C_M_AXI_GMEM_DATA_WIDTH ) ,
  .C_ID_WIDTH         ( 1   ) ,
  .C_NUM_CHANNELS     ( LP_NUM_READ_CHANNELS    ) ,
  .C_LENGTH_WIDTH     ( LP_LENGTH_WIDTH         ) ,
  .C_BURST_LEN        ( LP_AXI_BURST_LEN        ) ,
  .C_LOG_BURST_LEN    ( LP_LOG_BURST_LEN        ) ,
  .C_MAX_OUTSTANDING  ( LP_RD_MAX_OUTSTANDING   )
)
inst_axi_read_master ( 
  .aclk           ( ap_clk                 ) ,
  .areset         ( areset                 ) ,

  .ctrl_start     ( ap_start_pulse         ) ,
  .ctrl_done      ( read_done              ) ,
  .ctrl_offset    ( ctrl_offset            ) ,
  .ctrl_length    ( ctrl_length            ) ,
  .ctrl_prog_full ( ctrl_rd_fifo_prog_full ) ,

  .arvalid        ( m_axi_gmem_ARVALID     ) ,
  .arready        ( m_axi_gmem_ARREADY     ) ,
  .araddr         ( m_axi_gmem_ARADDR      ) ,
  .arid           (                        ) ,
  .arlen          ( m_axi_gmem_ARLEN       ) ,
  .arsize         (                        ) ,
  .rvalid         ( m_axi_gmem_RVALID      ) ,
  .rready         ( m_axi_gmem_RREADY      ) ,
  .rdata          ( m_axi_gmem_RDATA       ) ,
  .rlast          ( m_axi_gmem_RLAST       ) ,
  .rid            ( 1'b0                   ) ,
  .rresp          ( m_axi_gmem_RRESP       ) ,

  .m_tvalid       ( rd_tvalid              ) ,
  .m_tready       ( ~rd_tready_n           ) ,
  .m_tdata        ( rd_tdata               ) 
);

// xpm_fifo_sync: Synchronous FIFO
// Xilinx Parameterized Macro, Version 2016.4
xpm_fifo_sync # (
  .FIFO_MEMORY_TYPE          ("auto"),           //string; "auto", "block", "distributed", or "ultra";
  .ECC_MODE                  ("no_ecc"),         //string; "no_ecc" or "en_ecc";
  .FIFO_WRITE_DEPTH          (LP_RD_FIFO_DEPTH),   //positive integer
  .WRITE_DATA_WIDTH          (C_M_AXI_GMEM_DATA_WIDTH),        //positive integer
  .WR_DATA_COUNT_WIDTH       ($clog2(LP_RD_FIFO_DEPTH)+1),       //positive integer, Not used
  .PROG_FULL_THRESH          (LP_AXI_BURST_LEN-2),               //positive integer
  .FULL_RESET_VALUE          (1),                //positive integer; 0 or 1
  .READ_MODE                 ("fwft"),            //string; "std" or "fwft";
  .FIFO_READ_LATENCY         (1),                //positive integer;
  .READ_DATA_WIDTH           (C_M_AXI_GMEM_DATA_WIDTH),               //positive integer
  .RD_DATA_COUNT_WIDTH       ($clog2(LP_RD_FIFO_DEPTH)+1),               //positive integer, not used
  .PROG_EMPTY_THRESH         (10),               //positive integer, not used 
  .DOUT_RESET_VALUE          ("0"),              //string, don't care
  .WAKEUP_TIME               (0)                 //positive integer; 0 or 2;

) inst_rd_xpm_fifo_sync[LP_NUM_READ_CHANNELS-1:0] (
  .sleep         ( 1'b0             ) ,
  .rst           ( areset           ) ,
  .wr_clk        ( ap_clk           ) ,
  .wr_en         ( rd_tvalid        ) ,
  .din           ( rd_tdata         ) ,
  .full          ( rd_tready_n      ) ,
  .prog_full     ( ctrl_rd_fifo_prog_full) ,
  .wr_data_count (                  ) ,
  .overflow      (                  ) ,
  .wr_rst_busy   (                  ) ,
  .rd_en         ( rd_fifo_tready   ) ,
  .dout          ( rd_fifo_tdata    ) ,
  .empty         ( rd_fifo_tvalid_n ) ,
  .prog_empty    (                  ) ,
  .rd_data_count (                  ) ,
  .underflow     (                  ) ,
  .rd_rst_busy   (                  ) ,
  .injectsbiterr ( 1'b0             ) ,
  .injectdbiterr ( 1'b0             ) ,
  .sbiterr       (                  ) ,
  .dbiterr       (                  ) 

);

assign p0_TVALID = ~rd_fifo_tvalid_n; 
assign p0_TDATA = rd_fifo_tdata;
assign rd_fifo_tready = p0_TREADY;

endmodule : krnl_input_stage_rtl_int

`default_nettype wire
