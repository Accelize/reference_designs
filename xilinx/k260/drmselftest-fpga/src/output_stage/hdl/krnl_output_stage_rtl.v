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

module krnl_output_stage_rtl #(
  parameter integer  C_S_AXI_CONTROL_DATA_WIDTH = 32,
  parameter integer  C_S_AXI_CONTROL_ADDR_WIDTH = 6,
  parameter integer  C_M_AXI_GMEM_ADDR_WIDTH = 64,
  parameter integer  C_M_AXI_GMEM_DATA_WIDTH = 32
)
(
  // System signals
  input  wire                                    ap_clk,
  input  wire                                    ap_rst_n,
  // AXI4 master interface
  input  wire                                    m_axi_gmem_awready,
  output wire                                    m_axi_gmem_awvalid,
  output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]      m_axi_gmem_awaddr,
  output wire [7:0]                              m_axi_gmem_awlen,
  input  wire                                    m_axi_gmem_wready,
  output wire                                    m_axi_gmem_wvalid,
  output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]      m_axi_gmem_wdata,
  output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0]    m_axi_gmem_wstrb,
  output wire                                    m_axi_gmem_wlast,
  output wire                                    m_axi_gmem_bready,
  input  wire                                    m_axi_gmem_bvalid,
  input  wire [1:0]                              m_axi_gmem_bresp,
  input  wire                                    m_axi_gmem_arready,
  output wire                                    m_axi_gmem_arvalid,
  output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]      m_axi_gmem_araddr,
  output wire [7:0]                              m_axi_gmem_arlen,
  output wire                                    m_axi_gmem_rready,
  input  wire                                    m_axi_gmem_rvalid,
  input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0]    m_axi_gmem_rdata,
  input  wire                                    m_axi_gmem_rlast,
  input  wire [1:0]                              m_axi_gmem_rresp,
  // AXI4-Stream master interface
  output wire                                    p1_tready,
  input  wire                                    p1_tvalid,
  input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0]    p1_tdata,
  // AXI4-Lite slave interface
  output wire                                    s_axi_control_awready,
  input  wire                                    s_axi_control_awvalid,
  input  wire [C_S_AXI_CONTROL_ADDR_WIDTH-1:0]   s_axi_control_awaddr,
  output wire                                    s_axi_control_wready,
  input  wire                                    s_axi_control_wvalid,
  input  wire [C_S_AXI_CONTROL_DATA_WIDTH-1:0]   s_axi_control_wdata,
  input  wire [C_S_AXI_CONTROL_DATA_WIDTH/8-1:0] s_axi_control_wstrb,
  input  wire                                    s_axi_control_bready,
  output wire                                    s_axi_control_bvalid,
  output wire [1:0]                              s_axi_control_bresp,
  output wire                                    s_axi_control_arready,
  input  wire                                    s_axi_control_arvalid,
  input  wire [C_S_AXI_CONTROL_ADDR_WIDTH-1:0]   s_axi_control_araddr,
  input  wire                                    s_axi_control_rready,
  output wire                                    s_axi_control_rvalid,
  output wire [C_S_AXI_CONTROL_DATA_WIDTH-1:0]   s_axi_control_rdata,
  output wire [1:0]                              s_axi_control_rresp,
  output wire                                    interrupt
);

krnl_output_stage_rtl_int #(
  .C_S_AXI_CONTROL_DATA_WIDTH  ( C_S_AXI_CONTROL_DATA_WIDTH ),
  .C_S_AXI_CONTROL_ADDR_WIDTH  ( C_S_AXI_CONTROL_ADDR_WIDTH ),
  .C_M_AXI_GMEM_ADDR_WIDTH     ( C_M_AXI_GMEM_ADDR_WIDTH ),
  .C_M_AXI_GMEM_DATA_WIDTH     ( C_M_AXI_GMEM_DATA_WIDTH )
)
inst_krnl_output_stage_rtl_int (
  .ap_clk                 ( ap_clk ),
  .ap_rst_n               ( ap_rst_n ),
  .m_axi_gmem_AWREADY     ( m_axi_gmem_awready ),
  .m_axi_gmem_AWVALID     ( m_axi_gmem_awvalid ),
  .m_axi_gmem_AWADDR      ( m_axi_gmem_awaddr ),
  .m_axi_gmem_AWLEN       ( m_axi_gmem_awlen ),
  .m_axi_gmem_WREADY      ( m_axi_gmem_wready ),
  .m_axi_gmem_WVALID      ( m_axi_gmem_wvalid ),
  .m_axi_gmem_WDATA       ( m_axi_gmem_wdata ),
  .m_axi_gmem_WSTRB       ( m_axi_gmem_wstrb ),
  .m_axi_gmem_WLAST       ( m_axi_gmem_wlast ),
  .m_axi_gmem_BREADY      ( m_axi_gmem_bready ),
  .m_axi_gmem_BVALID      ( m_axi_gmem_bvalid ),
  .m_axi_gmem_BRESP       ( m_axi_gmem_bresp ),
  .m_axi_gmem_ARREADY     ( m_axi_gmem_arready ),
  .m_axi_gmem_ARVALID     ( m_axi_gmem_arvalid ),
  .m_axi_gmem_ARADDR      ( m_axi_gmem_araddr ),
  .m_axi_gmem_ARLEN       ( m_axi_gmem_arlen ),
  .m_axi_gmem_RREADY      ( m_axi_gmem_rready ),
  .m_axi_gmem_RVALID      ( m_axi_gmem_rvalid ),
  .m_axi_gmem_RDATA       ( m_axi_gmem_rdata ),
  .m_axi_gmem_RLAST       ( m_axi_gmem_rlast ),
  .m_axi_gmem_RRESP       ( m_axi_gmem_rresp ),
  .p1_TDATA               ( p1_tdata ),
  .p1_TVALID              ( p1_tvalid ),
  .p1_TREADY              ( p1_tready ),
  .s_axi_control_AWREADY  ( s_axi_control_awready ),
  .s_axi_control_AWVALID  ( s_axi_control_awvalid ),
  .s_axi_control_AWADDR   ( s_axi_control_awaddr ),
  .s_axi_control_WREADY   ( s_axi_control_wready ),
  .s_axi_control_WVALID   ( s_axi_control_wvalid ),
  .s_axi_control_WDATA    ( s_axi_control_wdata ),
  .s_axi_control_WSTRB    ( s_axi_control_wstrb ),
  .s_axi_control_BREADY   ( s_axi_control_bready ),
  .s_axi_control_BVALID   ( s_axi_control_bvalid ),
  .s_axi_control_BRESP    ( s_axi_control_bresp ),
  .s_axi_control_ARREADY  ( s_axi_control_arready ),
  .s_axi_control_ARVALID  ( s_axi_control_arvalid ),
  .s_axi_control_ARADDR   ( s_axi_control_araddr ),
  .s_axi_control_RREADY   ( s_axi_control_rready ),
  .s_axi_control_RVALID   ( s_axi_control_rvalid ),
  .s_axi_control_RDATA    ( s_axi_control_rdata ),
  .s_axi_control_RRESP    ( s_axi_control_rresp ),
  .interrupt              ( interrupt )
);

endmodule

`default_nettype wire