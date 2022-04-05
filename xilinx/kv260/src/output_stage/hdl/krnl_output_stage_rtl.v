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
  parameter integer  C_M_AXI_GMEM_ID_WIDTH = 1,
  parameter integer  C_M_AXI_GMEM_ADDR_WIDTH = 64,
  parameter integer  C_M_AXI_GMEM_DATA_WIDTH = 32
)
(
  // System signals
  input  wire                                    ap_clk,
  input  wire                                    ap_rst_n,
  // AXI4 master interface
  output wire                                    m_axi_gmem_awvalid,
  input  wire                                    m_axi_gmem_awready,
  output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]      m_axi_gmem_awaddr,
  output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]      m_axi_gmem_awid,
  output wire [7:0]                              m_axi_gmem_awlen,
  output wire [2:0]                              m_axi_gmem_awsize,
  // Tie-off AXI4 transaction options that are not being used.
  output wire [1:0]                              m_axi_gmem_awburst,
  output wire [1:0]                              m_axi_gmem_awlock,
  output wire [3:0]                              m_axi_gmem_awcache,
  output wire [2:0]                              m_axi_gmem_awprot,
  output wire [3:0]                              m_axi_gmem_awqos,
  output wire [3:0]                              m_axi_gmem_awregion,
  output wire                                    m_axi_gmem_wvalid,
  input  wire                                    m_axi_gmem_wready,
  output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]      m_axi_gmem_wdata,
  output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0]    m_axi_gmem_wstrb,
  output wire                                    m_axi_gmem_wlast,
  output wire                                    m_axi_gmem_arvalid,
  input  wire                                    m_axi_gmem_arready,
  output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]      m_axi_gmem_araddr,
  output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]        m_axi_gmem_arid,
  output wire [7:0]                              m_axi_gmem_arlen,
  output wire [2:0]                              m_axi_gmem_arsize,
  output wire [1:0]                              m_axi_gmem_arburst,
  output wire [1:0]                              m_axi_gmem_arlock,
  output wire [3:0]                              m_axi_gmem_arcache,
  output wire [2:0]                              m_axi_gmem_arprot,
  output wire [3:0]                              m_axi_gmem_arqos,
  output wire [3:0]                              m_axi_gmem_arregion,
  input  wire                                    m_axi_gmem_rvalid,
  output wire                                    m_axi_gmem_rready,
  input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0]    m_axi_gmem_rdata,
  input  wire                                    m_axi_gmem_rlast,
  input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]      m_axi_gmem_rid,
  input  wire [1:0]                              m_axi_gmem_rresp,
  input  wire                                    m_axi_gmem_bvalid,
  output wire                                    m_axi_gmem_bready,
  input  wire [1:0]                              m_axi_gmem_bresp,
  input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]      m_axi_gmem_bid,

  input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0]    p1_tdata,
  input  wire                                    p1_tvalid,
  output wire                                    p1_tready,
  // AXI4-Lite slave interface
  input  wire                                    s_axi_control_awvalid,
  output wire                                    s_axi_control_awready,
  input  wire [C_S_AXI_CONTROL_ADDR_WIDTH-1:0]   s_axi_control_awaddr,
  input  wire                                    s_axi_control_wvalid,
  output wire                                    s_axi_control_wready,
  input  wire [C_S_AXI_CONTROL_DATA_WIDTH-1:0]   s_axi_control_wdata,
  input  wire [C_S_AXI_CONTROL_DATA_WIDTH/8-1:0] s_axi_control_wstrb,
  input  wire                                    s_axi_control_arvalid,
  output wire                                    s_axi_control_arready,
  input  wire [C_S_AXI_CONTROL_ADDR_WIDTH-1:0]   s_axi_control_araddr,
  output wire                                    s_axi_control_rvalid,
  input  wire                                    s_axi_control_rready,
  output wire [C_S_AXI_CONTROL_DATA_WIDTH-1:0]   s_axi_control_rdata,
  output wire [1:0]                              s_axi_control_rresp,
  output wire                                    s_axi_control_bvalid,
  input  wire                                    s_axi_control_bready,
  output wire [1:0]                              s_axi_control_bresp,
  output wire                                    interrupt
);

krnl_output_stage_rtl_int #(
  .C_S_AXI_CONTROL_DATA_WIDTH  ( C_S_AXI_CONTROL_DATA_WIDTH ),
  .C_S_AXI_CONTROL_ADDR_WIDTH  ( C_S_AXI_CONTROL_ADDR_WIDTH ),
  .C_M_AXI_GMEM_ID_WIDTH       ( C_M_AXI_GMEM_ID_WIDTH ),
  .C_M_AXI_GMEM_ADDR_WIDTH     ( C_M_AXI_GMEM_ADDR_WIDTH ),
  .C_M_AXI_GMEM_DATA_WIDTH     ( C_M_AXI_GMEM_DATA_WIDTH )
)
inst_krnl_output_stage_rtl_int (
  .ap_clk                 ( ap_clk ),
  .ap_rst_n               ( ap_rst_n ),
  .m_axi_gmem_AWVALID     ( m_axi_gmem_awvalid ),
  .m_axi_gmem_AWREADY     ( m_axi_gmem_awready ),
  .m_axi_gmem_AWADDR      ( m_axi_gmem_awaddr ),
  .m_axi_gmem_AWID        ( m_axi_gmem_awid ),
  .m_axi_gmem_AWLEN       ( m_axi_gmem_awlen ),
  .m_axi_gmem_AWSIZE      ( m_axi_gmem_awsize ),
  .m_axi_gmem_AWBURST     ( m_axi_gmem_awburst ),
  .m_axi_gmem_AWLOCK      ( m_axi_gmem_awlock ),
  .m_axi_gmem_AWCACHE     ( m_axi_gmem_awcache ),
  .m_axi_gmem_AWPROT      ( m_axi_gmem_awprot ),
  .m_axi_gmem_AWQOS       ( m_axi_gmem_awqos ),
  .m_axi_gmem_AWREGION    ( m_axi_gmem_awregion ),
  .m_axi_gmem_WVALID      ( m_axi_gmem_wvalid ),
  .m_axi_gmem_WREADY      ( m_axi_gmem_wready ),
  .m_axi_gmem_WDATA       ( m_axi_gmem_wdata ),
  .m_axi_gmem_WSTRB       ( m_axi_gmem_wstrb ),
  .m_axi_gmem_WLAST       ( m_axi_gmem_wlast ),
  .m_axi_gmem_ARVALID     ( m_axi_gmem_arvalid ),
  .m_axi_gmem_ARREADY     ( m_axi_gmem_arready ),
  .m_axi_gmem_ARADDR      ( m_axi_gmem_araddr ),
  .m_axi_gmem_ARID        ( m_axi_gmem_arid ),
  .m_axi_gmem_ARLEN       ( m_axi_gmem_arlen ),
  .m_axi_gmem_ARSIZE      ( m_axi_gmem_arsize ),
  .m_axi_gmem_ARBURST     ( m_axi_gmem_arburst ),
  .m_axi_gmem_ARLOCK      ( m_axi_gmem_arlock ),
  .m_axi_gmem_ARCACHE     ( m_axi_gmem_arcache ),
  .m_axi_gmem_ARPROT      ( m_axi_gmem_arprot ),
  .m_axi_gmem_ARQOS       ( m_axi_gmem_arqos ),
  .m_axi_gmem_ARREGION    ( m_axi_gmem_arregion ),
  .m_axi_gmem_RVALID      ( m_axi_gmem_rvalid ),
  .m_axi_gmem_RREADY      ( m_axi_gmem_rready ),
  .m_axi_gmem_RDATA       ( m_axi_gmem_rdata ),
  .m_axi_gmem_RLAST       ( m_axi_gmem_rlast ),
  .m_axi_gmem_RID         ( m_axi_gmem_rid ),
  .m_axi_gmem_RRESP       ( m_axi_gmem_rresp ),
  .m_axi_gmem_BVALID      ( m_axi_gmem_bvalid ),
  .m_axi_gmem_BREADY      ( m_axi_gmem_bready ),
  .m_axi_gmem_BRESP       ( m_axi_gmem_bresp ),
  .m_axi_gmem_BID         ( m_axi_gmem_bid ),
  .p1_TDATA               ( p1_tdata ),
  .p1_TVALID              ( p1_tvalid ),
  .p1_TREADY              ( p1_tready ),
  .s_axi_control_AWVALID  ( s_axi_control_awvalid ),
  .s_axi_control_AWREADY  ( s_axi_control_awready ),
  .s_axi_control_AWADDR   ( s_axi_control_awaddr ),
  .s_axi_control_WVALID   ( s_axi_control_wvalid ),
  .s_axi_control_WREADY   ( s_axi_control_wready ),
  .s_axi_control_WDATA    ( s_axi_control_wdata ),
  .s_axi_control_WSTRB    ( s_axi_control_wstrb ),
  .s_axi_control_ARVALID  ( s_axi_control_arvalid ),
  .s_axi_control_ARREADY  ( s_axi_control_arready ),
  .s_axi_control_ARADDR   ( s_axi_control_araddr ),
  .s_axi_control_RVALID   ( s_axi_control_rvalid ),
  .s_axi_control_RREADY   ( s_axi_control_rready ),
  .s_axi_control_RDATA    ( s_axi_control_rdata ),
  .s_axi_control_RRESP    ( s_axi_control_rresp ),
  .s_axi_control_BVALID   ( s_axi_control_bvalid ),
  .s_axi_control_BREADY   ( s_axi_control_bready ),
  .s_axi_control_BRESP    ( s_axi_control_bresp ),
  .interrupt              ( interrupt )
);

endmodule : krnl_output_stage_rtl

`default_nettype wire
