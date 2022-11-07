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
// This module is an output stage which will perform AXI4 writes based on the 
// pipe input stream
//
// Data flow: AXI4-Stream input->Register Slice-> AXI4 Write Master
///////////////////////////////////////////////////////////////////////////////

// default_nettype of none prevents implicit wire declaration.
`default_nettype none
`timescale 1 ns / 1 ps 

module krnl_output_stage_rtl_int #( 
  parameter integer  C_S_AXI_CONTROL_DATA_WIDTH = 32,
  parameter integer  C_S_AXI_CONTROL_ADDR_WIDTH = 6,
  parameter integer  C_M_AXI_GMEM_ADDR_WIDTH = 64,
  parameter integer  C_M_AXI_GMEM_DATA_WIDTH = 32
)
(
  // System signals
  input  wire  ap_clk,
  input  wire  ap_rst_n,
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
  // AXI4-Stream slave interface
  input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] p1_TDATA,
  input  wire                                 p1_TVALID,
  output wire                                 p1_TREADY,
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
localparam integer LP_LENGTH_WIDTH       = 32;
localparam integer LP_DW_BYTES           = C_M_AXI_GMEM_DATA_WIDTH/8;
localparam integer LP_AXI_BURST_LEN      = 4096/LP_DW_BYTES < 256 ? 4096/LP_DW_BYTES : 256;
localparam integer LP_LOG_BURST_LEN      = $clog2(LP_AXI_BURST_LEN);


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

logic                               rs_tvalid;
logic                               rs_tready;
logic [C_M_AXI_GMEM_DATA_WIDTH-1:0] rs_tdata;

///////////////////////////////////////////////////////////////////////////////
// RTL Logic 
///////////////////////////////////////////////////////////////////////////////
// Tie-off unused AXI protocol features
assign m_axi_gmem_ARVALID  = 1'b0;
assign m_axi_gmem_ARADDR   = {C_M_AXI_GMEM_ADDR_WIDTH{1'b0}};
assign m_axi_gmem_ARLEN    = 8'b00;
assign m_axi_gmem_RREADY   = 1'b0;

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

// AXI4-Lite slave
krnl_output_stage_rtl_control_s_axi #(
  .C_S_AXI_ADDR_WIDTH( C_S_AXI_CONTROL_ADDR_WIDTH ),
  .C_S_AXI_DATA_WIDTH( C_S_AXI_CONTROL_DATA_WIDTH )
) 
inst_krnl_output_stage_control_s_axi (
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
  .output_r  ( ctrl_offset[0+:C_M_AXI_GMEM_ADDR_WIDTH] ) ,
  .size      ( ctrl_length[0+:LP_LENGTH_WIDTH]         )
);

// AXI4 Write Master
krnl_output_stage_rtl_axi_write_master #( 
  .C_ADDR_WIDTH       ( C_M_AXI_GMEM_ADDR_WIDTH ) ,
  .C_DATA_WIDTH       ( C_M_AXI_GMEM_DATA_WIDTH ) ,
  .C_LENGTH_WIDTH     ( LP_LENGTH_WIDTH         ) ,
  .C_BURST_LEN        ( LP_AXI_BURST_LEN        ) ,
  .C_LOG_BURST_LEN    ( LP_LOG_BURST_LEN        ) 
)
inst_axi_write_master ( 
  .aclk           ( ap_clk                 ) ,
  .areset         ( areset                 ) ,

  .ctrl_start     ( ap_start_pulse         ) ,
  .ctrl_done      ( ap_done                ) ,
  .ctrl_offset    ( ctrl_offset            ) ,
  .ctrl_length    ( ctrl_length            ) ,

  .awvalid        ( m_axi_gmem_AWVALID     ) ,
  .awready        ( m_axi_gmem_AWREADY     ) ,
  .awaddr         ( m_axi_gmem_AWADDR      ) ,
  .awlen          ( m_axi_gmem_AWLEN       ) ,
  .awsize         (                        ) ,

  .wvalid         ( m_axi_gmem_WVALID      ) ,
  .wready         ( m_axi_gmem_WREADY      ) ,
  .wdata          ( m_axi_gmem_WDATA       ) ,
  .wstrb          ( m_axi_gmem_WSTRB       ) ,
  .wlast          ( m_axi_gmem_WLAST       ) ,

  .bvalid         ( m_axi_gmem_BVALID      ) ,
  .bready         ( m_axi_gmem_BREADY      ) ,
  .bresp          ( m_axi_gmem_BRESP       ) ,

  .s_tvalid       ( rs_tvalid              ) ,
  .s_tready       ( rs_tready              ) ,
  .s_tdata        ( rs_tdata               ) 
);

// Register slice used for timing isolation and to de-assert p1_TREADY when idle.
krnl_output_stage_rtl_register_slice #(
  .C_TDATA_WIDTH (C_M_AXI_GMEM_DATA_WIDTH)
)
inst_register_slice (
  .aclk (ap_clk),
  .areset(areset | ap_idle),

  .s_tvalid (p1_TVALID),
  .s_tready (p1_TREADY),
  .s_tdata  (p1_TDATA),

  .m_tvalid (rs_tvalid),
  .m_tready (rs_tready),
  .m_tdata  (rs_tdata)
);

endmodule : krnl_output_stage_rtl_int

`default_nettype wire
